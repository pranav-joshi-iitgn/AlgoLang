##### Program

- Program $\to$ Statements

##### Statements Structure

- Statements $\to$ Statement Statements
- Statements $\to$ $\epsilon$
- Statement $\to$ Loop
- Statement $\to$ IfStatement
- Statement $\to$ ElseIfStatement
- Statement $\to$ ElseStatement
- Statement $\to$ SingleStatement ``;``

##### Control Flow & Blocks

- Loop            $\to$ `while` SOPLogic Block
- IfStatement     $\to$ `if` SOPLogic Block
- ElseIfStatement $\to$ `elif` SOPLogic Block
- ElseStatement   $\to$ `else` Block
- Block           $\to$ `{` Statements `}`

##### Single Statements

- SingleStatement $\to$ PrintStatement
- SingleStatement $\to$ RunStatement
- SingleStatement $\to$ Dictionary
- SingleStatement $\to$ ReturnStatement
- SingleStatement $\to$ PlotStatement
- SingleStatement $\to$ Break
- SingleStatement $\to$ Continue
- SingleStatement $\to$ Definition
- SingleStatement $\to$ Deletion
- SingleStatement $\to$ QGate
- SingleStatement $\to$ Measurement
- SingleStatement $\to$ ClearQC
- SingleStatement $\to$ Assignment

##### Specific Single Statement Implementations

- PrintStatement $\to$ `print` CommaSeparatedValues
- RunStatement   $\to$ `run` SOPLogic
- RunStatement   $\to$ `run` SOPLogic `with` CommaSeparatedValues
- Dictionary     $\to$ `dict` Assignable
- ReturnStatement$\to$ `return` SOPLogic
- ReturnStatement$\to$ `return`
- PlotStatement  $\to$ `plot` CommaSeparatedValues
- Break          $\to$ `breakloop`
- Continue       $\to$ `skipit`
- Definition     $\to$ `let` Id
- Definition     $\to$ `let` Id `=` SOPLogic
- Deletion       $\to$ `delete` Id
- QGate          $\to$ `QG` Id CommaSeparatedValues
- Measurement    $\to$ `measure` SOPLogic `into` Id
- ClearQC        $\to$ `clearQ`
- Assignment     $\to$ Assignable `=` SOPLogic

##### Expressions (Ordered by Precedence - Lowest to Highest)

###### OR (Left Associative)
- SOPLogic   $\to$ SOPLogic `or` MinTerm
- SOPLogic   $\to$ MinTerm

###### AND (Left Associative)
- MinTerm    $\to$ MinTerm `and` LogicLiteral
- MinTerm    $\to$ LogicLiteral

###### NOT (Prefix)
- LogicLiteral $\to$ `not` Comparison
- LogicLiteral $\to$ Comparison

###### Comparison Ops (Left Associative)
- Comparison $\to$ Expression CompOp Expression
- Comparison $\to$ Expression
- CompOp     $\to$ `==` | `>` | `<` | `>=` | `<=` | `!=`

###### Addition/Subtraction (Left Associative)
- Expression $\to$ Expression AddOp Term
- Expression $\to$ Term
- AddOp      $\to$ `+` | `-`

###### Multiplication/Division/Modulo (Left Associative)
- Term       $\to$ Term MulOp ExponentTower
- Term       $\to$ ExponentTower
- MulOp      $\to$ `*` | `/` | `//` | `%` | `mod` | `div`

###### Exponentiation (Right Associative)
- ExponentTower $\to$ Power `^` ExponentTower
- ExponentTower $\to$ Power

###### Unary Plus/Minus (Prefix)
- Power      $\to$ `+` Unary
- Power      $\to$ `-` Unary
- Power      $\to$ Unary

###### Function Call / Indexing / Atom (Postfix/Base)
- Unary      $\to$ Atom `(` CommaSeparatedValues `)`
- Unary      $\to$ Atom `[` SOPLogic `]`
- Unary      $\to$ Atom

###### Basic Units / Literals
- Atom       $\to$ Int
- Atom       $\to$ Float
- Atom       $\to$ Str
- Atom       $\to$ Id
- Atom       $\to$ ListLiteral
- Atom       $\to$ `(` SOPLogic `)`
- Atom       $\to$ Block
- Atom       $\to$ AlgDefinition
- Atom       $\to$ ListDefinition
- Atom       $\to$ VectorDefinition

##### Assignable Targets

- Assignable $\to$ Id
- Assignable $\to$ Atom `[` SOPLogic `]`

##### Comma-Separated Lists

- CommaSeparatedValues $\to$ SOPLogic `,` CommaSeparatedValues
- CommaSeparatedValues $\to$ SOPLogic
- CommaSeparatedValues $\to$ $\epsilon$

##### Function Definition Arguments

- Arguments  $\to$ Id `,` Arguments
- Arguments  $\to$ Id
- Arguments  $\to$ $\epsilon$

##### Specific Literal Forms

- AlgDefinition  $\to$ `alg` `(` Arguments `)` Block
- ListLiteral    $\to$ `(` CommaSeparatedValues `)`
- ListDefinition $\to$ `list` SOPLogic
- VectorDefinition $\to$ `vec` SOPLogic

##### Base Terminals (from `LEXER.py`)

###### Id
Identifier token (e.g., `myVar`)
###### Int
Integer literal token (e.g., `123`)
###### Float
Float literal token (e.g., `3.14`)
###### Str
String literal token (e.g., `"hello"` or `'world'`)
###### Keywords
`while`, `if`, `else`, `elif`, `in`, `and`, `or`, `not`, `print`, `delete`, `run`, `list`, `return`, `alg`, `with`, `vec`, `plot`, `breakloop`, `skipit`, `mod`, `div`, `let`, `QG`, `measure`, `into`, `clearQ`
###### Operators
`+`, `-`, `*`, `/`, `//`, `%`, `^`, `<`, `>`, `==`, `<=`, `>=`, `!=`, `=`
###### Delimiters
`(`, `)`, `{`, `}`, `[`, `]`, `;`, `,`
