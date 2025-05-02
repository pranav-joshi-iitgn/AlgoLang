# SHELL.py
import sys
import os
import re
import traceback

# --- Import required components from your language modules ---
# Ensure LEXER.py and SYNTAX.py are in the same directory or Python path
try:
    # Assuming COLOR_MAP_PT and keywords are available in LEXER.py
    from LEXER import lex, HighLight, COLOR_MAP_PT, keywords as lexer_keywords
    # Import necessary components from SYNTAX.py (provided file)
    from SYNTAX import Statements, PrintError, SYMBOLSTACK, DEFAULT_SYMBOLS, set_symbolstack, to_tuple
except ImportError as e:
    print(f"Error importing LEXER or SYNTAX module: {e}", file=sys.stderr)
    print("Please ensure LEXER.py and SYNTAX.py are in the current directory or Python path.", file=sys.stderr)
    sys.exit(1)
except Exception as e:
    print(f"Error during initial import: {type(e).__name__}: {e}", file=sys.stderr)
    sys.exit(1)


# --- Prompt Toolkit Imports ---
try:
    from prompt_toolkit import prompt
    from prompt_toolkit.key_binding import KeyBindings
    from prompt_toolkit.lexers import Lexer
    from prompt_toolkit.styles import Style, merge_styles
    from prompt_toolkit.document import Document
    from prompt_toolkit.completion import WordCompleter
    from prompt_toolkit.history import FileHistory
    from prompt_toolkit.styles.named_colors import NAMED_COLORS # For validation if needed
    from prompt_toolkit.keys import Keys
except ImportError as e:
    print(f"Error importing prompt_toolkit: {e}", file=sys.stderr)
    print("Please install prompt_toolkit: pip install prompt-toolkit", file=sys.stderr)
    sys.exit(1)

# --- Helper function to clean token types for style names ---
def clean_style_name(token_type):
    """Replaces invalid characters in token types for use as style names."""
    cleaned = re.sub(r'[=."\'?]', '_', str(token_type)) # Added ? just in case
    # Ensure it starts validly
    if not cleaned or not (cleaned[0].isalpha() or cleaned[0] == '_'):
        cleaned = 'tok_' + cleaned
    # Replace potential double underscores resulting from cleaning
    cleaned = cleaned.replace('__', '_')
    return cleaned

# 1. Define the Custom Style for prompt_toolkit
# Revised color scheme for better readability (VSCode dark theme inspired)
REVISED_COLOR_MAP_PT = {
    "id": "#9cdcfe",        # Light Blue (identifiers)
    "str": "#ce9178",       # Orangey/Brown (strings)
    "\"str": "#ce9178",     # Orangey/Brown (strings) - Ensure consistency
    "\'str": "#ce9178",     # Orangey/Brown (strings) - Ensure consistency
    "int": "#b5cea8",       # Greenish (numbers)
    "float": "#b5cea8",     # Greenish (numbers)
    "kw": "#c586c0",        # Purplish/Pink (keywords)
    "op1": "#ffd700",       # Gold (operators)
    "op2": "#ffd700",       # Gold (operators)
    "op2=": "#ffd700",      # Gold (operators)
    "op1=": "#ffd700",      # Gold (operators)
    "op12": "#ffd700",      # Gold (operators)
    "brak": "#d4d4d4",      # Off-white (brackets, delimiters)
    "com": "#6a9955",       # Green (comments)
    "com_": "#6a9955",      # Green (comments)
    "id.": "#9cdcfe",       # Light Blue (identifiers) - Handle dot case
    "unknown": "bg:#ff0000 #ffffff", # White on Red (errors)
    "sp": "",               # Default for spaces/newlines (often inherits default)
}

# Add any missing types from COLOR_MAP_PT from LEXER.py if necessary
# Ensure all keys used by the lexer have an entry, even if empty ("")
if 'COLOR_MAP_PT' in globals():
    for key in COLOR_MAP_PT:
        if key not in REVISED_COLOR_MAP_PT:
            # Use original color if defined, otherwise default
            original_color = COLOR_MAP_PT.get(key, "")
            REVISED_COLOR_MAP_PT[key] = original_color if original_color else ""


# Create style dictionary using cleaned names
style_dict_cleaned = {}
valid_keys = set()
for tok_type, color in REVISED_COLOR_MAP_PT.items():
    if not color: continue # Skip empty colors
    cleaned_name = clean_style_name(tok_type)
    valid_keys.add(cleaned_name) # Track valid style names we created
    style_class = f'lexer.{cleaned_name}'
    # Apply bold/italic based on original token type
    is_keyword = tok_type == 'kw'
    is_comment = tok_type in ('com', 'com_')
    font_style = "bold" if is_keyword else "italic" if is_comment else ""
    style_value = f"{color} {font_style}".strip()
    style_dict_cleaned[style_class] = style_value

# Add default style for text not matched by the lexer
style_dict_cleaned[''] = '#d4d4d4' # Default text color (off-white)
# Add styles for prompt-toolkit specific elements if desired
style_dict_cleaned['prompt'] = 'bold #ffffff' # White bold prompt
style_dict_cleaned['completion-menu.completion.current'] = 'bg:#00aaaa #000000'
style_dict_cleaned['completion-menu.completion'] = 'bg:#008888 #ffffff'

algo_lang_style = Style.from_dict(style_dict_cleaned)

# 2. Create the Custom Lexer (using cleaned names)
class AlgoLangLexer(Lexer):
    def __init__(self):
        self._cache = {}
        self._cache_key = ""
        # Store valid style names generated from REVISED_COLOR_MAP_PT
        self.valid_style_names = valid_keys

    def lex_document(self, document: Document):
        # Cache results per document text
        if self._cache_key == document.text:
            lines_styles = self._cache
        else:
            lines_styles = []
            try:
                # Use keep_comments=True for interactive highlighting
                tokens = lex(document.text, keep_spaces=True, keep_comments=True)
                current_line_styles = []
                for token_type, text in tokens:
                    # Clean the token type to create a valid style class name
                    cleaned_name = clean_style_name(token_type)
                    # Use the cleaned name only if it corresponds to a defined style
                    style_class = f"class:lexer.{cleaned_name}" if cleaned_name in self.valid_style_names else ""

                    # Split token text by newlines to assign styles line by line
                    parts = text.split('\n')
                    # Add style for the first part (or the whole if no newline)
                    current_line_styles.append((style_class, parts[0]))
                    # If newlines were present, finalize current line and start new ones
                    for i in range(1, len(parts)):
                        lines_styles.append(current_line_styles) # Finalize previous line
                        current_line_styles = [(style_class, parts[i])] # Start new line with current style

                lines_styles.append(current_line_styles) # Add the last line being built

            except ValueError as e:
                # Handle known lexer errors: style the whole line as unknown
                print(f"Lexer Error: {e}", file=sys.stderr) # Non-intrusive log
                # Simple fallback: style entire document as unknown
                lines_styles = [[('class:lexer.unknown', document.text)]]
            except Exception as e:
                 # Catch other unexpected lexer errors
                 print(f"Unexpected Lexer Error: {type(e).__name__}: {e}", file=sys.stderr)
                 lines_styles = [[('class:lexer.unknown', document.text)]] # Fallback

            # Cache the result
            self._cache = lines_styles
            self._cache_key = document.text

        # The required callable for prompt_toolkit
        def get_line(lineno: int):
            return lines_styles[lineno] if lineno < len(lines_styles) else []

        return get_line


# 3. Define the input function using prompt_toolkit (Updated Bindings)
def get_input_interactive(prompt_message="AlgoLang> ", history=None):
    bindings = KeyBindings()
    algo_lexer_instance = AlgoLangLexer()

    # Use 'c-j' for Control+J to submit
    @bindings.add('c-j')
    def _(event):
        event.app.exit(result=event.cli.current_buffer.text)

    # Bind 'enter' to insert a newline
    @bindings.add('enter')
    def _(event):
        event.cli.current_buffer.insert_text('\n')

    # --- Enhanced Tab Binding ---
    @bindings.add('tab')
    def _(event):
        """
        Handles the Tab key press.
        Initiates completion or selects the next completion.
        """
        buff = event.app.current_buffer
        if buff.complete_state:
            buff.complete_next()
        else:
            # Start completion, selecting the first item by default
            buff.start_completion(select_first=True)

    # --- Shift+Tab Binding ---
    @bindings.add(Keys.BackTab) # Keys.BackTab corresponds to Shift+Tab
    def _(event):
        """
        Handles the Shift+Tab key press (BackTab).
        Selects the previous completion.
        """
        buff = event.app.current_buffer
        if buff.complete_state:
            buff.complete_previous()
        # Optional: else: event.app.output.beep() # Beep if no completion active

    # Optional: Basic keyword completer
    if 'lexer_keywords' in globals():
        kw_completer = WordCompleter(lexer_keywords, ignore_case=True)
    else:
        kw_completer = None
        print("Warning: Keywords not found for completion.", file=sys.stderr)

    # Run the prompt with the custom lexer, style, bindings, completer, history
    text = prompt(
        prompt_message,
        multiline=True,
        lexer=algo_lexer_instance,
        style=algo_lang_style,
        key_bindings=bindings, # Pass our specific bindings
        completer=kw_completer,
        history=history,
        reserve_space_for_menu=4,
    )
    return text

# 4. Main Shell Loop
def run_shell():
    print("Starting AlgoLang Interactive Shell...")
    print("Type your code. Press Enter for new line.")
    print("Press Ctrl+J to evaluate.")
    print("Type 'exit' or 'quit' or press Ctrl+C/Ctrl+D to exit.")

    # --- Initialize Symbol Table ONCE ---
    # This relies on SYNTAX.py initializing SYMBOLSTACK globally when imported.
    # Add explicit initialization if needed, e.g.:
    # if not SYMBOLSTACK: # Check if it's empty
    #    set_symbolstack([DEFAULT_SYMBOLS.copy()])

    # Setup command history
    history = FileHistory('.algolang_history')

    while True:
        try:
            # Get input from the user
            text_input = get_input_interactive(history=history)

            # --- Exit/Skip ---
            input_strip = text_input.strip()
            if input_strip.lower() in ['exit', 'quit']:
                break
            if not input_strip: # Skip empty input lines
                continue

            # --- Lexing (for evaluation) ---
            # Use keep_comments=False for SYNTAX parser
            tokens = [] # Initialize tokens
            try:
                tokens = lex(text_input, keep_comments=False)
                if not tokens: # Skip if only comments/whitespace resulted in no tokens
                    continue
            except ValueError as e:
                print(f"\x1b[31;1mLexer Error:\x1b[0m\x1b[31m {e}\x1b[0m") # Bold Red Error
                continue
            except Exception as e:
                print(f"\x1b[31;1mUnexpected Lexer Error:\x1b[0m\x1b[31m {type(e).__name__}: {e}\x1b[0m")
                continue

            # --- Parsing ---
            parser = Statements()
            parse_result = None # Initialize
            parsed_ast = None
            try:
                # Parse modifies the parser object in place if successful
                parse_result = parser.parse(tokens)

                if isinstance(parse_result, ValueError):
                    print("\x1b[31;1mParser Error:\x1b[0m") # Bold Red header
                    PrintError(parse_result) # Use SYNTAX's error printing
                    continue
                else:
                    # Successfully parsed, the AST is within the parser object
                    parsed_ast = parser

            except Exception as e:
                 # Catch potential errors during parsing itself
                 print(f"\x1b[31;1mInternal Parsing Error:\x1b[0m\x1b[31m {type(e).__name__}: {e}\x1b[0m")
                 traceback.print_exc() # Print detailed traceback for debugging
                 continue

            # --- Evaluation ---
            if parsed_ast: # Proceed only if parsing was successful
                try:
                    eval_result = parsed_ast.eval()
                    # Optionally print the result if it's not None
                    if eval_result is not None:
                        # Use SYNTAX.to_tuple for consistent output if available
                        output_str = str(to_tuple(eval_result)) if 'to_tuple' in globals() and callable(to_tuple) else str(eval_result)
                        # Ensure output starts on a new line if needed, Green color
                        print(f"\x1b[32mOut: {output_str}\x1b[0m")

                except ValueError as e:
                    print("\x1b[31;1mRuntime Error:\x1b[0m") # Bold Red header
                    PrintError(e) # Use SYNTAX's error printing
                    continue
                except Exception as e:
                    # Catch other potential runtime errors (KeyError, TypeError etc.)
                    print(f"\x1b[31;1mUnexpected Runtime Error:\x1b[0m\x1b[31m {type(e).__name__}: {e}\x1b[0m")
                    traceback.print_exc() # Print traceback for debugging
                    continue

        except KeyboardInterrupt:
            # Handle Ctrl+C gracefully
            print("\nExiting...")
            break
        except EOFError:
            # Handle Ctrl+D gracefully
            print("\nExiting...")
            break
        except Exception as e:
            # Catch any other unexpected errors in the main loop
            print(f"\x1b[31;1mUnexpected Shell Error:\x1b[0m\x1b[31m {type(e).__name__}: {e}\x1b[0m")
            traceback.print_exc()
            # Optionally decide whether to break or continue
            # break

# 5. Entry Point
if __name__ == "__main__":
    run_shell()
