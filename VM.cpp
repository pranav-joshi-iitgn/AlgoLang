// === SECTION 1: Headers, Types, Constants, Globals ===

    // --- Includes ---
    #include <iostream>
    #include <vector>
    #include <unordered_map>
    #include <map>
    #include <string>
    #include <complex>
    #include <cstdint>
    #include <cmath>
    #include <limits>
    #include <iomanip>
    #include <fstream>
    #include <sstream>
    #include <random>
    #include <algorithm>
    #include <tuple>
    #include <stdexcept>
    #include <cstring>
    #include <cstdlib>
    #include <array>
    #include <cassert> // For basic unit tests
    #include <optional> // For syscall return (C++17)

    using namespace std;

    // --- Add other Type Aliases ---
    using u8 = uint8_t;
    using i8 = int8_t;
    using i16 = int16_t;
    using u32 = uint32_t;
    using i32 = int32_t;
    using u64 = uint64_t;
    using i64 = int64_t;


    // --- Type Aliases ---
    using QuantumState = vector<complex<double>>;
    using GateMatrix = vector<vector<complex<double>>>;
    using ParsedInstruction = pair<int, vector<string>>;
    using SegmentName = string;

    // --- MIPS Constants ---
    const uint32_t CODE_BASE_ADDRESS = 0x00400000;
    const uint32_t DATA_BASE_ADDRESS = 0x10010000;
    const uint32_t HEAP_META_BASE_ADDRESS = 0x60000000;
    const uint32_t STACK_BASE_ADDRESS = 0x60000000;

    // --- Segment Boundaries ---
    const uint32_t TEXT_SEGMENT_END = DATA_BASE_ADDRESS;
    const uint64_t STACK_ALLOCATED_SIZE_BYTES = 64ULL * 1024 * 1024;
    const uint32_t STACK_SEGMENT_BOTTOM = STACK_BASE_ADDRESS - static_cast<uint32_t>(STACK_ALLOCATED_SIZE_BYTES);
    const uint32_t STATIC_DATA_END = STACK_SEGMENT_BOTTOM;
    const uint32_t HEAP_META_END_ADDRESS = 0x80000000; // Up to 2GB mark

    // --- Opcode Constants ---
    const int OP_UNKNOWN = -1;
    const int OP_ADD = 1, OP_SUB = 2, OP_ADDI = 3, OP_AND = 4, OP_OR = 5;
    const int OP_NOR = 6, OP_ORI = 7, OP_ANDI = 8, OP_XORI = 9;
    const int OP_LW = 10, OP_SW = 11, OP_LB = 12, OP_SB = 13, OP_LA = 14, OP_LI = 15;
    const int OP_BEQ = 20, OP_BNE = 21, OP_J = 22, OP_JAL = 23, OP_JR = 24;
    const int OP_SLT = 30, OP_SGT = 31, OP_SLL = 32, OP_SRL = 33, OP_SLLV = 34, OP_SRLV = 35;
    const int OP_MOVE = 40;
    const int OP_MULT = 50, OP_MFLO = 51, OP_MFHI = 52;
    const int OP_MTC1 = 60, OP_MFC1 = 61, OP_ADD_S = 62, OP_SUB_S = 63, OP_MUL_S = 64;
    const int OP_DIV_S = 65, OP_L_S = 66, OP_S_S = 67, OP_CVT_S_W = 68, OP_CVT_W_S = 69;
    const int OP_MOV_S = 70;
    const int OP_SYSCALL = 80;
    const int OP_H = 100, OP_X = 101, OP_CNOT = 102, OP_MEASURE = 103, OP_RESET = 104;

    // --- Mapping for Parser ---
    map<string, int> OPCODE_STR_TO_ID; // Initialized in sim_initialize

    // --- Quantum Constants ---
    const int NUM_QUBITS = 5;
    const size_t STATE_SIZE = 1 << NUM_QUBITS;
    double _SQRT2_INV; // Initialized in sim_initialize

    // --- Quantum Gate Matrices ---
    GateMatrix H_GATE; // Initialized in sim_initialize
    GateMatrix X_GATE; // Initialized in sim_initialize

    // --- Floating Point Tolerance ---
    const double _FLOAT_ZERO_TOLERANCE = 1e-9;

    // --- Global Simulator State ---
    // Memory Segments
    vector<uint8_t> mem_text;
    vector<uint8_t> mem_data;
    vector<uint8_t> mem_stack;
    unordered_map<uint32_t, uint8_t> mem_high;

    // Core State
    unordered_map<string, uint32_t> labels;
    vector<ParsedInstruction> parsed_instructions;
    vector<string> instruction_strings;
    unordered_map<string, uint32_t> data_segment;
    uint32_t pc = CODE_BASE_ADDRESS;
    string current_segment = ".text";
    uint32_t heap_pointer = DATA_BASE_ADDRESS;

    // Register Storage (Globals)
    int32_t reg_at = 0, reg_v0 = 0, reg_v1 = 0, reg_k0 = 0, reg_k1 = 0;
    uint32_t reg_gp = 0x10008000;
    uint32_t reg_sp = STACK_BASE_ADDRESS;
    int32_t reg_fp = 0, reg_ra = 0;
    array<int32_t, 4> reg_a{};
    array<int32_t, 10> reg_t{};
    array<int32_t, 10> reg_s{};
    int32_t reg_hi = 0, reg_lo = 0;
    array<int32_t, 32> reg_f{}; // Stores int bits

    // Quantum State
    QuantumState quantum_state; // Resized in sim_initialize

// === END SECTION 1 ===

// --- Unit Test for Section 1 ---
    void test_globals_and_constants() {
        cout << "Testing Globals & Constants..." << endl;
        assert(CODE_BASE_ADDRESS == 0x00400000);
        assert(DATA_BASE_ADDRESS == 0x10010000);
        assert(STACK_BASE_ADDRESS == 0x60000000);
        assert(HEAP_META_BASE_ADDRESS == 0x60000000);
        assert(TEXT_SEGMENT_END == DATA_BASE_ADDRESS);
        assert(STATIC_DATA_END == STACK_SEGMENT_BOTTOM);
        assert(HEAP_META_END_ADDRESS == 0x80000000);
        assert(STACK_SEGMENT_BOTTOM == 0x5C000000); // Verify calculation
        assert(OP_ADD == 1);
        assert(OP_H == 100);
        assert(NUM_QUBITS == 5);
        assert(STATE_SIZE == 32);
        // Check initial values (assuming called after potential sim_initialize)
        // assert(pc == CODE_BASE_ADDRESS); // Depends on when test runs
        // assert(reg_sp == STACK_BASE_ADDRESS);
        // assert(reg_a[0] == 0); // Assuming zero initialization
        // assert(reg_f[0] == 0);
        cout << "Globals & Constants Test Passed." << endl;
    }
// --- End Unit Test ---


// === SECTION 2: sim_initialize ===
    void sim_initialize() {
        // --- Reset Memory Segments ---
        mem_text.clear(); mem_text.shrink_to_fit(); // Release memory
        mem_data.clear(); mem_data.shrink_to_fit();
        mem_stack.clear(); mem_stack.shrink_to_fit();
        mem_high.clear(); // Clear map

        // --- Reset Core State ---
        labels.clear();
        parsed_instructions.clear(); parsed_instructions.shrink_to_fit();
        instruction_strings.clear(); instruction_strings.shrink_to_fit();
        data_segment.clear();
        pc = CODE_BASE_ADDRESS;
        current_segment = ".text";
        heap_pointer = DATA_BASE_ADDRESS;

        // --- Reset Registers ---
        reg_at = 0; reg_v0 = 0; reg_v1 = 0; reg_k0 = 0; reg_k1 = 0;
        reg_gp = 0x10008000;
        reg_sp = STACK_BASE_ADDRESS;
        reg_fp = 0; reg_ra = 0;
        fill(reg_a.begin(), reg_a.end(), 0);
        fill(reg_t.begin(), reg_t.end(), 0);
        fill(reg_s.begin(), reg_s.end(), 0);
        reg_hi = 0; reg_lo = 0;
        fill(reg_f.begin(), reg_f.end(), 0);

        // --- Reset Quantum State ---
        quantum_state.assign(STATE_SIZE, complex<double>(0.0, 0.0));
        if (!quantum_state.empty()) {
            quantum_state[0] = complex<double>(1.0, 0.0);
        }

        // --- Initialize Quantum Constants/Gates ---
        _SQRT2_INV = 1.0 / std::sqrt(2.0);
        H_GATE = {
            {complex<double>(_SQRT2_INV, 0.0), complex<double>(_SQRT2_INV, 0.0)},
            {complex<double>(_SQRT2_INV, 0.0), complex<double>(-_SQRT2_INV, 0.0)}
        };
        X_GATE = {
            {complex<double>(0.0, 0.0), complex<double>(1.0, 0.0)},
            {complex<double>(1.0, 0.0), complex<double>(0.0, 0.0)}
        };

        // --- Initialize Opcode Map ---
        OPCODE_STR_TO_ID = {
            {"add", OP_ADD}, {"sub", OP_SUB}, {"addi", OP_ADDI}, {"lw", OP_LW}, {"move", OP_MOVE}, {"sw", OP_SW},
            {"beq", OP_BEQ}, {"bne", OP_BNE}, {"j", OP_J}, {"jal", OP_JAL}, {"jr", OP_JR}, {"slt", OP_SLT},
            {"sgt", OP_SGT}, {"sll", OP_SLL}, {"srl", OP_SRL}, {"la", OP_LA}, {"li", OP_LI}, {"and", OP_AND},
            {"or", OP_OR}, {"nor", OP_NOR}, {"mult", OP_MULT}, {"mflo", OP_MFLO}, {"mfhi", OP_MFHI},
            {"mtc1", OP_MTC1}, {"mfc1", OP_MFC1}, {"syscall", OP_SYSCALL}, {"add.s", OP_ADD_S}, {"sub.s", OP_SUB_S},
            {"mul.s", OP_MUL_S}, {"div.s", OP_DIV_S}, {"l.s", OP_L_S}, {"s.s", OP_S_S}, {"cvt.s.w", OP_CVT_S_W},
            {"cvt.w.s", OP_CVT_W_S}, {"mov.s", OP_MOV_S}, {"lb", OP_LB}, {"sb", OP_SB}, {"sllv", OP_SLLV},
            {"srlv", OP_SRLV}, {"H", OP_H}, {"X", OP_X}, {"CNOT", OP_CNOT}, {"measure", OP_MEASURE},
            {"reset", OP_RESET}, {"ori", OP_ORI}, {"andi", OP_ANDI}, {"xori", OP_XORI}
        };
    }
// === END SECTION 2 ===

// --- Unit Test for Section 2 ---
    void test_sim_initialize() {
        cout << "Testing sim_initialize..." << endl;

        // Set some dummy initial state
        mem_data.push_back(1);
        mem_high[0x70000000] = 2;
        labels["dummy"] = 0x1234;
        pc = 0xFFFF;
        reg_v0 = 99;
        quantum_state.assign(STATE_SIZE, complex<double>(0.5, 0.5));

        // Call initialize
        sim_initialize();

        // Check if state is reset
        assert(mem_text.empty());
        assert(mem_data.empty());
        assert(mem_stack.empty());
        assert(mem_high.empty());
        assert(labels.empty());
        assert(parsed_instructions.empty());
        assert(instruction_strings.empty());
        assert(data_segment.empty());
        assert(pc == CODE_BASE_ADDRESS);
        assert(current_segment == ".text");
        assert(heap_pointer == DATA_BASE_ADDRESS);
        assert(reg_v0 == 0);
        assert(reg_a[0] == 0);
        assert(reg_f[31] == 0);
        assert(quantum_state.size() == STATE_SIZE);
        assert(abs(quantum_state[0].real() - 1.0) < 1e-9);
        assert(abs(quantum_state[0].imag()) < 1e-9);
        if (STATE_SIZE > 1) {
            assert(abs(quantum_state[1].real()) < 1e-9); // Check another element is zero
        }
        assert(!OPCODE_STR_TO_ID.empty()); // Check map initialized
        assert(OPCODE_STR_TO_ID["add"] == OP_ADD);
        assert(abs(H_GATE[0][0].real() - _SQRT2_INV) < 1e-9); // Check gates initialized

        cout << "sim_initialize Test Passed." << endl;
    }
// --- End Unit Test ---

// === SECTION 3: Memory Segmentation and Access ===

    // Enum already defined in Section 1
    enum class SegmentType { TEXT, DATA, STACK, HIGH, INVALID };

    // Max list extension size (bytes) - adjust if needed
    const size_t MAX_LIST_EXTEND = 16 * 1024 * 1024;

    // Forward declare for use in _set_mem_byte
    void _ensure_segment_size(vector<uint8_t>& segment_list, size_t required_index);

    tuple<SegmentType, uint32_t, SegmentName> _get_segment_info(uint32_t address) {
        // 1. Check Text Segment
        if (address >= CODE_BASE_ADDRESS && address < TEXT_SEGMENT_END) {
            uint32_t offset = address - CODE_BASE_ADDRESS;
            return make_tuple(SegmentType::TEXT, offset, "Text");
        }

        // 2. Check Stack Segment
        if (address > STACK_SEGMENT_BOTTOM && address < STACK_BASE_ADDRESS) {
            uint32_t offset = STACK_BASE_ADDRESS - address; // Reversed index calculation
            return make_tuple(SegmentType::STACK, offset, "Stack");
        }

        // 3. Check High Memory (Heap/Metadata) -> Dictionary
        if (address >= HEAP_META_BASE_ADDRESS && address < HEAP_META_END_ADDRESS) {
            // For dictionary, return address itself as the key (index_or_addr holds address)
            return make_tuple(SegmentType::HIGH, address, "Heap/Meta");
        }

        // 4. Check Static Data Segment
        if (address >= DATA_BASE_ADDRESS && address < STATIC_DATA_END) {
            uint32_t offset = address - DATA_BASE_ADDRESS;
            return make_tuple(SegmentType::DATA, offset, "Static Data");
        }

        // If execution reaches here, none of the checks passed
        // cerr << "--- ERROR: All segment checks failed for address " << hex << address << " ---" << endl; // Keep commented unless debugging
        return make_tuple(SegmentType::INVALID, 0, "Invalid"); // Indicate failure
    }


    void _ensure_segment_size(vector<uint8_t>& segment_list, size_t required_index) {
        size_t current_size = segment_list.size();
        // Need size to be at least required_index + 1
        if (required_index >= current_size) {
            size_t new_size = required_index + 1;
            size_t needed_elements = new_size - current_size;

            if (needed_elements > MAX_LIST_EXTEND) {
                // cerr << "Error: Attempting excessive list resize (" << needed_elements << " bytes)" << endl;
                throw runtime_error("Excessive list resize request: " + to_string(needed_elements));
            }
            try {
                // Use resize which can be more efficient than extend loop
                segment_list.resize(new_size, 0);
            } catch (const bad_alloc& ba) {
                cerr << "CRITICAL bad_alloc during list resize: " << ba.what() << endl;
                cerr << "Requested new size: " << new_size << endl;
                throw; // Re-throw
            }
        }
    }

    uint8_t _get_mem_byte(uint32_t address) {
        auto [seg_type, index_or_addr, seg_name] = _get_segment_info(address);

        try {
            switch (seg_type) {
                case SegmentType::TEXT:
                    return (index_or_addr < mem_text.size()) ? mem_text.at(index_or_addr) : 0;
                case SegmentType::DATA:
                    return (index_or_addr < mem_data.size()) ? mem_data.at(index_or_addr) : 0;
                case SegmentType::STACK:
                    return (index_or_addr < mem_stack.size()) ? mem_stack.at(index_or_addr) : 0;
                case SegmentType::HIGH:
                    {
                        auto it = mem_high.find(index_or_addr); // index_or_addr holds address
                        return (it != mem_high.end()) ? it->second : 0;
                    }
                case SegmentType::INVALID:
                default:
                    // cerr << "Memory Read Error: Address " << hex << address << " is outside defined segments." << endl;
                    return 0; // Return 0 for invalid address read
            }
        } catch (const out_of_range& oor) { // Catch vector::at exception
            // This implies index was >= size(), should return 0 per logic above
            // cerr << "Warning: vector::at out_of_range during _get_mem_byte at " << hex << address << ": " << oor.what() << endl;
            return 0;
        } catch (const exception& e) {
            cerr << "Unexpected Memory Read Error at " << hex << address << ": " << e.what() << endl;
            return 0;
        }
    }

    void _set_mem_byte(uint32_t address, uint8_t value) {
        auto [seg_type, index_or_addr, seg_name] = _get_segment_info(address);

        try {
            switch (seg_type) {
                case SegmentType::TEXT:
                    _ensure_segment_size(mem_text, index_or_addr);
                    mem_text.at(index_or_addr) = value; // Use .at() for safety? Or [] faster? Use [] for performance
                    // mem_text[index_or_addr] = value;
                    break;
                case SegmentType::DATA:
                    _ensure_segment_size(mem_data, index_or_addr);
                    mem_data[index_or_addr] = value;
                    break;
                case SegmentType::STACK:
                    _ensure_segment_size(mem_stack, index_or_addr);
                    mem_stack[index_or_addr] = value;
                    break;
                case SegmentType::HIGH:
                    // Dictionary write using address (index_or_addr holds address)
                    mem_high[index_or_addr] = value;
                    // Optional: Add dict size check here
                    break;
                case SegmentType::INVALID:
                default:
                    throw runtime_error("Memory address " + to_string(address) + " is outside defined segments.");
            }
        } catch (const runtime_error& re) { // Catch segment errors / resize errors
            cerr << "Memory Write Error: " << re.what() << endl;
            exit(1);
        } catch (const bad_alloc& ba) { // Catch resize allocation errors
            cerr << "CRITICAL bad_alloc during memory write at " << hex << address << ": " << ba.what() << endl;
            exit(1);
        }
        // Removed generic Exception catch from Python to let specific errors propagate if needed
    }

    int32_t _get_mem_word(uint32_t address) {
        if (address % 4 != 0) {
            throw runtime_error("Unaligned word read " + to_string(address));
        }
        uint8_t byte3 = _get_mem_byte(address);
        uint8_t byte2 = _get_mem_byte(address + 1);
        uint8_t byte1 = _get_mem_byte(address + 2);
        uint8_t byte0 = _get_mem_byte(address + 3);

        uint32_t word_val_u = (static_cast<uint32_t>(byte3) << 24) |
                            (static_cast<uint32_t>(byte2) << 16) |
                            (static_cast<uint32_t>(byte1) << 8)  |
                            (static_cast<uint32_t>(byte0));
        return static_cast<int32_t>(word_val_u);
    }

    void _set_mem_word(uint32_t address, int32_t value) {
        if (address % 4 != 0) {
            throw runtime_error("Unaligned word write " + to_string(address));
        }
        uint32_t value_u = static_cast<uint32_t>(value);
        uint8_t byte3 = (value_u >> 24) & 0xFF;
        uint8_t byte2 = (value_u >> 16) & 0xFF;
        uint8_t byte1 = (value_u >> 8)  & 0xFF;
        uint8_t byte0 = value_u & 0xFF;

        _set_mem_byte(address,     byte3);
        _set_mem_byte(address + 1, byte2);
        _set_mem_byte(address + 2, byte1);
        _set_mem_byte(address + 3, byte0);
    }
// === END SECTION 3 ===

// --- Unit Test for Section 3 ---
    void test_memory_access() {
        cout << "Testing Memory Access..." << endl;
        sim_initialize(); // Ensure clean state

        // --- Test _get_segment_info ---
        auto [type1, idx1, name1] = _get_segment_info(CODE_BASE_ADDRESS);
        assert(type1 == SegmentType::TEXT && idx1 == 0);
        auto [type2, idx2, name2] = _get_segment_info(DATA_BASE_ADDRESS);
        assert(type2 == SegmentType::DATA && idx2 == 0);
        auto [type3, idx3, name3] = _get_segment_info(STACK_BASE_ADDRESS); // Top byte
        assert(type3 == SegmentType::HIGH && idx3 == HEAP_META_BASE_ADDRESS);
        auto [type4, idx4, name4] = _get_segment_info(STACK_BASE_ADDRESS - 1); // Next byte down
        assert(type4 == SegmentType::STACK && idx4 == 1);
        auto [type5, idx5, name5] = _get_segment_info(STACK_SEGMENT_BOTTOM + 1); // Byte above bottom
        assert(type5 == SegmentType::STACK);
        auto [type6, idx6, name6] = _get_segment_info(HEAP_META_BASE_ADDRESS); // Heap base
        assert(type6 == SegmentType::HIGH && idx6 == HEAP_META_BASE_ADDRESS);
        auto [type7, idx7, name7] = _get_segment_info(0x7fffffff); // High address
        assert(type7 == SegmentType::HIGH && idx7 == 0x7fffffff);
        auto [type8, idx8, name8] = _get_segment_info(0x00000000); // Invalid low
        assert(type8 == SegmentType::INVALID);
        auto [type9, idx9, name9] = _get_segment_info(HEAP_META_END_ADDRESS); // Invalid high end
        assert(type9 == SegmentType::INVALID);
        auto [type10, idx10, name10] = _get_segment_info(STATIC_DATA_END); // Boundary check
        assert(type10 != SegmentType::DATA); // Should not match data (< STATIC_DATA_END)
        assert(type10 == SegmentType::INVALID || type10 == SegmentType::STACK); // Depends on exact boundary overlap check


        // --- Test _ensure_segment_size & _set/_get_mem_byte ---
        // Data Segment
        _set_mem_byte(DATA_BASE_ADDRESS + 10, 123);
        assert(mem_data.size() >= 11);
        assert(mem_data[10] == 123);
        assert(_get_mem_byte(DATA_BASE_ADDRESS + 10) == 123);
        assert(_get_mem_byte(DATA_BASE_ADDRESS + 11) == 0); // Uninitialized read

        // Stack Segment (Reversed index)
        _set_mem_byte(STACK_BASE_ADDRESS - 5, 234); // Offset = 5
        assert(mem_stack.size() >= 6);
        assert(mem_stack[5] == 234);
        assert(_get_mem_byte(STACK_BASE_ADDRESS - 5) == 234);
        assert(_get_mem_byte(STACK_BASE_ADDRESS - 6) == 0);

        // High Memory (Dictionary)
        _set_mem_byte(HEAP_META_BASE_ADDRESS + 100, 111);
        assert(mem_high.count(HEAP_META_BASE_ADDRESS + 100));
        assert(mem_high[HEAP_META_BASE_ADDRESS + 100] == 111);
        assert(_get_mem_byte(HEAP_META_BASE_ADDRESS + 100) == 111);
        assert(_get_mem_byte(HEAP_META_BASE_ADDRESS + 101) == 0); // Uninitialized read

        // --- Test _set/_get_mem_word ---
        _set_mem_word(DATA_BASE_ADDRESS + 20, 0x12345678); // Aligned write
        assert(_get_mem_byte(DATA_BASE_ADDRESS + 20) == 0x12); // Big Endian
        assert(_get_mem_byte(DATA_BASE_ADDRESS + 21) == 0x34);
        assert(_get_mem_byte(DATA_BASE_ADDRESS + 22) == 0x56);
        assert(_get_mem_byte(DATA_BASE_ADDRESS + 23) == 0x78);
        assert(_get_mem_word(DATA_BASE_ADDRESS + 20) == 0x12345678);

        _set_mem_word(STACK_BASE_ADDRESS - 8, -1); // Negative value (0xFFFFFFFF)
        assert(_get_mem_byte(STACK_BASE_ADDRESS - 8) == 0xFF); // Offset 7
        assert(_get_mem_byte(STACK_BASE_ADDRESS - 5) == 0xFF); // Offset 4
        assert(_get_mem_word(STACK_BASE_ADDRESS - 8) == -1);

        _set_mem_word(HEAP_META_BASE_ADDRESS + 200, 1000);
        assert(_get_mem_word(HEAP_META_BASE_ADDRESS + 200) == 1000);

        // Test unaligned exceptions (optional, as they terminate)
        bool caught_unaligned_read = false;
        try { _get_mem_word(DATA_BASE_ADDRESS + 1); } catch (const runtime_error&) { caught_unaligned_read = true; }
        assert(caught_unaligned_read);

        bool caught_unaligned_write = false;
        try { _set_mem_word(STACK_BASE_ADDRESS - 1, 0); } catch (const runtime_error&) { caught_unaligned_write = true; }
        assert(caught_unaligned_write);


        cout << "Memory Access Test Passed." << endl;
    }
// --- End Unit Test ---

// === SECTION 4: Register Accessors ===

    // Use int32_t for register values consistent with MIPS 32-bit architecture
    int32_t _get_register_value(const string& reg_name) {
        if (reg_name == "$zero" || reg_name == "$0") return 0;
        if (reg_name == "$at") return reg_at;
        if (reg_name == "$v0") return reg_v0;
        if (reg_name == "$v1") return reg_v1;
        if (reg_name == "$gp") return static_cast<int32_t>(reg_gp);
        if (reg_name == "$sp") return static_cast<int32_t>(reg_sp);
        if (reg_name == "$fp") return reg_fp;
        if (reg_name == "$ra") return reg_ra;
        if (reg_name == "$k0") return reg_k0;
        if (reg_name == "$k1") return reg_k1;
        if (reg_name == "$hi") return reg_hi;
        if (reg_name == "$lo") return reg_lo;

        try {
            // Use rfind for starts_with simulation (C++11/14)
            if (reg_name.rfind("$a", 0) == 0) {
                size_t idx = stoul(reg_name.substr(2)); // Use unsigned for index
                return reg_a.at(idx);
            }
            if (reg_name.rfind("$t", 0) == 0) {
                size_t idx = stoul(reg_name.substr(2));
                return reg_t.at(idx);
            }
            if (reg_name.rfind("$s", 0) == 0) {
                size_t idx = stoul(reg_name.substr(2));
                return reg_s.at(idx);
            }
            if (reg_name.rfind("$f", 0) == 0) {
                size_t idx = stoul(reg_name.substr(2));
                return reg_f.at(idx); // Returns int bits
            }
        } catch (const invalid_argument& ia) {
            throw runtime_error("Invalid register name format: " + reg_name);
        } catch (const out_of_range& oor) {
            throw runtime_error("Invalid register index or format: " + reg_name);
        }
        throw runtime_error("Unknown register: " + reg_name);
    }

    void _set_register_value(const string& reg_name, int32_t value) {
        if (reg_name == "$zero" || reg_name == "$0") return;

        if (reg_name == "$at") { reg_at = value; return; }
        if (reg_name == "$v0") { reg_v0 = value; return; }
        if (reg_name == "$v1") { reg_v1 = value; return; }
        if (reg_name == "$gp") { reg_gp = static_cast<uint32_t>(value); return; }
        if (reg_name == "$sp") { reg_sp = static_cast<uint32_t>(value); return; }
        if (reg_name == "$fp") { reg_fp = value; return; }
        if (reg_name == "$ra") { reg_ra = value; return; }
        if (reg_name == "$k0") { reg_k0 = value; return; }
        if (reg_name == "$k1") { reg_k1 = value; return; }
        if (reg_name == "$hi") { reg_hi = value; return; }
        if (reg_name == "$lo") { reg_lo = value; return; }

        try {
            if (reg_name.rfind("$a", 0) == 0) {
                size_t idx = stoul(reg_name.substr(2));
                reg_a.at(idx) = value; return;
            }
            if (reg_name.rfind("$t", 0) == 0) {
                size_t idx = stoul(reg_name.substr(2));
                reg_t.at(idx) = value; return;
            }
            if (reg_name.rfind("$s", 0) == 0) {
                size_t idx = stoul(reg_name.substr(2));
                reg_s.at(idx) = value; return;
            }
            if (reg_name.rfind("$f", 0) == 0) {
                size_t idx = stoul(reg_name.substr(2));
                reg_f.at(idx) = value; return; // Stores int bits
            }
        } catch (const invalid_argument& ia) {
            throw runtime_error("Invalid register name format for set: " + reg_name);
        } catch (const out_of_range& oor) {
            throw runtime_error("Invalid register index or format for set: " + reg_name);
        }
        throw runtime_error("Unknown register for set: " + reg_name);
    }

    // Forward declaration
    double int_bits_to_float(int32_t bits);

    // Helper to get float value from FPR bits
    double _get_float_from_fpr(const string& reg_name) {
        int32_t bits = _get_register_value(reg_name); // Gets raw int bits
        return int_bits_to_float(bits);
    }
// === END SECTION 4 ===

// --- Unit Test for Section 4 ---
    void test_register_access() {
        cout << "Testing Register Access..." << endl;
        sim_initialize(); // Reset registers

        // Test setting and getting GPRs
        _set_register_value("$v0", 123);
        assert(_get_register_value("$v0") == 123);
        _set_register_value("$a1", -10);
        assert(_get_register_value("$a1") == -10);
        _set_register_value("$t9", 999);
        assert(_get_register_value("$t9") == 999);
        _set_register_value("$sp", 0x5FFF0000); // Set address type
        assert(_get_register_value("$sp") == static_cast<int32_t>(0x5FFF0000)); // Get as int32

        // Test $zero
        assert(_get_register_value("$zero") == 0);
        _set_register_value("$zero", 100); // Should have no effect
        assert(_get_register_value("$zero") == 0);

        // Test setting and getting FPRs (as bits)
        _set_register_value("$f5", 0x41480000); // Bit pattern for 12.5f
        assert(_get_register_value("$f5") == 0x41480000);

        // Test _get_float_from_fpr
        assert(abs(_get_float_from_fpr("$f5") - 12.5) < 1e-6);

        // Test bounds checking (using .at() which throws out_of_range)
        bool caught_gpr_oor = false;
        try { _get_register_value("$a4"); } catch (const runtime_error&) { caught_gpr_oor = true; }
        assert(caught_gpr_oor);

        bool caught_fpr_oor = false;
        try { _set_register_value("$f32", 0); } catch (const runtime_error&) { caught_fpr_oor = true; }
        assert(caught_fpr_oor);

        // Test invalid name
        bool caught_invalid = false;
        try { _get_register_value("$x1"); } catch (const runtime_error&) { caught_invalid = true; }
        assert(caught_invalid);

        cout << "Register Access Test Passed." << endl;
    }
// --- End Unit Test ---

// === SECTION 5: Utilities ===

    int32_t float_to_int_bits(double f) {
        static_assert(sizeof(float) == sizeof(int32_t), "Requires float to be 32-bit");
        // Handle NaN and Inf potentially differently if needed, or rely on IEEE 754 representation
        float f32 = static_cast<float>(f);
        int32_t bits;
        memcpy(&bits, &f32, sizeof(float));
        // NOTE: Assumes host and target have same endianness for float representation
        // Add byte swapping here if cross-endian simulation is required.
        return bits;
    }

    double int_bits_to_float(int32_t bits) {
        static_assert(sizeof(float) == sizeof(int32_t), "Requires float to be 32-bit");
        float f32;
        // NOTE: Assumes host and target have same endianness. Add byte swap if needed.
        memcpy(&f32, &bits, sizeof(float));
        return static_cast<double>(f32);
    }

    // Helper function for parsing integer literals (including '0b')
    long long parse_integer_literal(const string& s) {
        if (s.empty()) throw runtime_error("Empty immediate value");
        string clean_s = s; size_t first = clean_s.find_first_not_of(" \t\n\r");
        if (string::npos == first) throw runtime_error("Whitespace immediate value");
        size_t last = clean_s.find_last_not_of(" \t\n\r"); clean_s = clean_s.substr(first, (last - first + 1));
    
        size_t pos = 0;
        int base = 0; // Default: Let stoull auto-detect 0x (hex) and 0 (octal)
        bool is_negative = false;
        string number_part = clean_s; // Keep track of the part passed to stoull
    
        // Handle sign FIRST
        if (!number_part.empty() && number_part[0] == '-') { is_negative = true; number_part = number_part.substr(1); }
        else if (!number_part.empty() && number_part[0] == '+') { number_part = number_part.substr(1); }
        if (number_part.empty()) throw runtime_error("Invalid number format after sign handling");
    
        // Handle binary prefix MANUALLY (stoull doesn't support base 2 with '0b')
        if (number_part.rfind("0b", 0) == 0 || number_part.rfind("0B", 0) == 0) {
            base = 2;
            number_part = number_part.substr(2); // Remove prefix
            if (number_part.empty()) throw runtime_error("Invalid binary literal (empty after 0b)");
            // Check if all remaining chars are 0 or 1
            for (char c : number_part) {
                if (c != '0' && c != '1') throw runtime_error("Invalid binary literal (contains non-0/1)");
            }
        }
        // For base 0, stoull handles "0x" hex and "0" octal prefixes.
        // No need to manually set base 16 or 8.
    
        // Now call stoull with the potentially modified number_part and base
        unsigned long long ull_val;
        try {
            ull_val = stoull(number_part, &pos, base); // Use detected base (0 or 2)
        } catch (const std::out_of_range& oor) {
             throw runtime_error("Integer literal out of unsigned long long range");
        } catch (const std::invalid_argument& ia) {
            // This can happen if the string starts with non-digits (after prefix/sign removal)
             throw runtime_error("Invalid integer literal format (stoull invalid_argument)");
        }
    
    
        // Check if the entire relevant part of the string was consumed
        if (pos != number_part.length()) {
             // This indicates trailing characters that are invalid for the detected base
             throw runtime_error("Invalid integer literal format (incomplete parse)"); // <<< THE ORIGINAL EXCEPTION
        }
    
        long long ll_val;
        // Apply sign AFTER conversion, checking for overflow
        if (is_negative) {
            // Use unsigned comparison to correctly handle potential overflow around LLONG_MIN
            unsigned long long limit = static_cast<unsigned long long>(numeric_limits<long long>::max()) + 1ULL;
            if (ull_val > limit) {
                throw runtime_error("Integer literal negation overflow (too large magnitude)");
            } else if (ull_val == limit) {
                // Special case for LLONG_MIN
                ll_val = numeric_limits<long long>::min();
            } else {
                ll_val = -static_cast<long long>(ull_val);
            }
        } else {
            // Check positive overflow
            if (ull_val > static_cast<unsigned long long>(numeric_limits<long long>::max())) {
                throw runtime_error("Integer literal overflow (positive)");
            }
            ll_val = static_cast<long long>(ull_val);
        }
    
        return ll_val;
    }
    

    int32_t _parse_immediate(const string& imm_str, const string& instr_name = "Instr") {
        // Trim input string
        string imm_str_strip = imm_str;
        size_t first = imm_str_strip.find_first_not_of(" \t\n\r");
        if (string::npos == first) throw runtime_error("Empty/whitespace immediate in " + instr_name);
        size_t last = imm_str_strip.find_last_not_of(" \t\n\r");
        imm_str_strip = imm_str_strip.substr(first, (last - first + 1));

        // Handle Char Literal
        if (imm_str_strip.length() >= 3 && imm_str_strip.front() == '\'' && imm_str_strip.back() == '\'') {
            string char_content = imm_str_strip.substr(1, imm_str_strip.length() - 2);
            if (char_content == "\\n") return '\n'; if (char_content == "\\t") return '\t';
            if (char_content == "\\0") return '\0'; if (char_content == "\\\\") return '\\';
            if (char_content == "\\'") return '\''; if (char_content == " ") return ' ';
            if (char_content.length() == 1) return static_cast<int32_t>(static_cast<unsigned char>(char_content[0]));
            throw runtime_error("Invalid char literal '" + imm_str_strip + "' in " + instr_name);
        }

        // Handle Integer Literal
        long long val_ll; // Use long long to detect overflow
        size_t pos = 0;
        string num_to_parse = imm_str_strip;
        int base = 0; // Let stoll auto-detect hex/octal

        try {
            // Manually handle binary prefix '0b'/'0B'
            bool is_negative = (!num_to_parse.empty() && num_to_parse[0] == '-');
            string check_part = is_negative ? num_to_parse.substr(1) : num_to_parse; // Part after potential sign
            if (check_part.empty() && is_negative) throw runtime_error("Only '-' provided");

            if (check_part.rfind("0b", 0) == 0 || check_part.rfind("0B", 0) == 0) {
                base = 2;
                string bin_part = check_part.substr(2);
                if (bin_part.empty()) throw runtime_error("Invalid binary literal (empty after 0b)");
                for (char c : bin_part) if (c != '0' && c != '1') throw runtime_error("Invalid binary literal (non-0/1)");
                // Parse binary part as unsigned, then apply sign if needed
                unsigned long long ull_val = stoull(bin_part, &pos, base);
                if (pos != bin_part.length()) throw runtime_error("Invalid binary literal (incomplete parse)");
                // Apply sign carefully checking range
                if (is_negative) {
                    if (ull_val > (static_cast<unsigned long long>(numeric_limits<long long>::max()) + 1ULL)) throw std::out_of_range("Binary literal negation overflow");
                    if (ull_val == (static_cast<unsigned long long>(numeric_limits<long long>::max()) + 1ULL)) val_ll = numeric_limits<long long>::min();
                    else val_ll = -static_cast<long long>(ull_val);
                } else {
                    if (ull_val > static_cast<unsigned long long>(numeric_limits<long long>::max())) throw std::out_of_range("Binary literal overflow");
                    val_ll = static_cast<long long>(ull_val);
                }
            } else {
                // Let stoll handle decimal, octal (0), hex (0x) including signs
                val_ll = stoll(num_to_parse, &pos, base); // Use base 0 auto-detect
                if (pos != num_to_parse.length()) {
                    throw runtime_error("Invalid integer literal format (incomplete parse)");
                }
            }

            // Range Check: Check if the value fits the pattern of a 32-bit number
            // This means checking if it's within [-2147483648, 4294967295]
            const long long min_32_pattern = static_cast<long long>(numeric_limits<int32_t>::min()); //-2147483648LL;
            const unsigned long long max_32_pattern_ull = numeric_limits<uint32_t>::max(); // 4294967295ULL;

            // Need to compare carefully due to types
            bool out_of_range = false;
            if (val_ll < min_32_pattern) { // Too negative
                out_of_range = true;
            } else if (val_ll >= 0) { // Check against UINT32_MAX if positive or zero
                if (static_cast<unsigned long long>(val_ll) > max_32_pattern_ull) {
                    out_of_range = true;
                }
            }
            // If val_ll is negative but >= min_32_pattern, it's fine.

            if (out_of_range) {
                stringstream ss;
                ss << "Immediate value '" << imm_str_strip << "' (" << val_ll
                << ") cannot be represented as a 32-bit pattern in " << instr_name;
                throw runtime_error(ss.str());
            }

            // Cast the valid pattern to uint32_t, then to int32_t for storage
            return static_cast<int32_t>(static_cast<uint32_t>(val_ll));

        } catch (const std::out_of_range& oor) {
            // This means the literal exceeded even long long range during stoll/stoull
            throw runtime_error("Immediate value '" + imm_str_strip + "' is out of parsable range in " + instr_name);
        } catch (const std::invalid_argument& ia) {
            // This means stoll/stoull couldn't parse at all
            throw runtime_error("Invalid immediate value format '" + imm_str_strip + "' in " + instr_name);
        } catch (const exception& e) { // Catch other specific errors if needed
            throw runtime_error("Error parsing immediate '" + imm_str_strip + "' in " + instr_name + ": " + e.what());
        }
    }

    pair<int32_t, string> _parse_offset_register(const string& operand_raw) { // Rename input parameter
        // --- START ADDED TRIM ---
        string operand = operand_raw; // Make a mutable copy
        size_t first = operand.find_first_not_of(" \t\n\r");
        if (string::npos == first) { // Handle empty or all-whitespace input
             throw runtime_error("Invalid memory address format (empty): '" + operand_raw + "'. Expected offset(register).");
        }
        size_t last = operand.find_last_not_of(" \t\n\r");
        operand = operand.substr(first, (last - first + 1));
        // --- END ADDED TRIM ---
    
    
        size_t open_paren = operand.find('(');
        size_t close_paren = operand.rfind(')'); // Use rfind for last ')'
    
        // Basic structure check (Now runs on the trimmed string)
        if (open_paren == string::npos || close_paren == string::npos || open_paren >= close_paren || close_paren != operand.length() - 1) {
            // Use operand_raw in error message to show original input if desired
            throw runtime_error("Invalid memory address format '" + operand_raw + "'. Expected offset(register).");
        }
    
        string offset_str = operand.substr(0, open_paren);
        string reg_str = operand.substr(open_paren + 1, close_paren - open_paren - 1);
    
        // Trim parts is now less critical but doesn't hurt
        size_t off_first = offset_str.find_first_not_of(" \t"); if(off_first != string::npos) offset_str = offset_str.substr(off_first);
        // No need to trim end of offset_str as substr(0, open_paren) handles it.
        size_t reg_first = reg_str.find_first_not_of(" \t"); if(reg_first != string::npos) reg_str = reg_str.substr(reg_first);
        size_t reg_last = reg_str.find_last_not_of(" \t"); if(reg_last != string::npos) reg_str = reg_str.substr(0, reg_last + 1);
    
    
        if (reg_str.empty() || reg_str[0] != '$') {
            throw runtime_error("Invalid register part in '" + operand_raw + "'.");
        }
        if (offset_str.empty()) {
            throw runtime_error("Missing offset part in '" + operand_raw + "'.");
        }
    
        try {
            int32_t offset = _parse_immediate(offset_str, "_parse_offset_register");
            return {offset, reg_str};
        } catch (const exception& e) {
            // Use operand_raw in error message
            throw runtime_error("Invalid offset part '" + offset_str + "' in '" + operand_raw + "': " + e.what());
        }
    }

// === END SECTION 5 ===

// --- Unit Test for Section 5 ---
    void test_utilities() {
        cout << "Testing Utilities..." << endl;

        // Test float <-> int bits
        assert(float_to_int_bits(12.5) == 0x41480000);
        assert(abs(int_bits_to_float(0x41480000) - 12.5) < 1e-6);
        assert(float_to_int_bits(-1.0) == static_cast<int32_t>(0xBF800000));
        assert(abs(int_bits_to_float(0xBF800000) - (-1.0)) < 1e-6);

        // Test _parse_immediate
        assert(_parse_immediate("123") == 123);
        assert(_parse_immediate("-10") == -10);
        assert(_parse_immediate("0x1A") == 26);
        assert(_parse_immediate("010") == 8); // Octal
        // Test binary parsing helper
        assert(parse_integer_literal("0b1010") == 10);
        assert(parse_integer_literal("-0b11") == -3);
        assert(_parse_immediate("0b1100") == 12); // Test integration
        assert(_parse_immediate("'A'") == 65);
        assert(_parse_immediate("'\\n'") == 10);
        assert(_parse_immediate("' '") == 32);

        // Test _parse_offset_register
        auto [off1, reg1] = _parse_offset_register("16($sp)");
        assert(off1 == 16 && reg1 == "$sp");
        auto [off2, reg2] = _parse_offset_register("-8($fp)");
        assert(off2 == -8 && reg2 == "$fp");
        auto [off3, reg3] = _parse_offset_register("0($t0)");
        assert(off3 == 0 && reg3 == "$t0");
        // Test with spaces
        auto [off4, reg4] = _parse_offset_register("  100  (  $s1  )  ");
        assert(off4 == 100 && reg4 == "$s1");


        // Test exception cases (optional)
        bool caught_bad_imm = false;
        try { _parse_immediate("abc"); } catch (const runtime_error&) { caught_bad_imm = true; }
        assert(caught_bad_imm);

        bool caught_bad_off = false;
        try { _parse_offset_register("($sp)"); } catch (const runtime_error&) { caught_bad_off = true; }
        assert(caught_bad_off);

        bool caught_bad_reg = false;
        try { _parse_offset_register("16sp)"); } catch (const runtime_error&) { caught_bad_reg = true; }
        assert(caught_bad_reg);

        cout << "Utilities Test Passed." << endl;
    }
// --- End Unit Test ---

// === SECTION 6: Loading and Parsing ===

    // --- String/Parsing Helpers ---

    // Helper to split string by single delimiter (basic version)
    vector<string> split_string(const string& s, char delimiter) {
        vector<string> tokens;
        string token;
        istringstream tokenStream(s);
        while (getline(tokenStream, token, delimiter)) {
            // Simple trim (leading/trailing whitespace)
            size_t first = token.find_first_not_of(" \t\n\r");
            if (string::npos == first) continue;
            size_t last = token.find_last_not_of(" \t\n\r");
            tokens.push_back(token.substr(first, (last - first + 1)));
        }
        if (!s.empty() && s.back() == delimiter && tokens.empty() && s.find_first_not_of(" \t\n\r") != string::npos) {
            // Handle case like "label:;" -> results in one empty string after split if not handled
            // Or if the line ends with the delimiter but isn't just whitespace
            // This logic might need refinement based on exact desired split behavior
        } else if (!s.empty() && s.back() == delimiter && !tokenStream.eof()) {
            // Add an empty string if the line ends with the delimiter and wasn't just whitespace
            // tokens.push_back(""); // Decide if trailing empty fields are needed
        }
        return tokens;
    }

    // Helper to split only once at the first occurrence of a delimiter string
    pair<string, string> split_string_once(const string& s, const string& delimiter) {
        size_t pos = s.find(delimiter);
        if (pos == string::npos) {
            // Trim the whole string if no delimiter found
            size_t first = s.find_first_not_of(" \t");
            if (first == string::npos) return {"", ""};
            size_t last = s.find_last_not_of(" \t");
            return {s.substr(first, (last - first + 1)), ""};
        }
        // Trim parts
        string part1 = s.substr(0, pos);
        string part2 = s.substr(pos + delimiter.length());
        size_t p1_first = part1.find_first_not_of(" \t"); size_t p1_last = part1.find_last_not_of(" \t");
        if(p1_first == string::npos) part1 = ""; else part1 = part1.substr(p1_first, (p1_last - p1_first + 1));
        size_t p2_first = part2.find_first_not_of(" \t"); size_t p2_last = part2.find_last_not_of(" \t");
        if(p2_first == string::npos) part2 = ""; else part2 = part2.substr(p2_first, (p2_last - p2_first + 1));

        return {part1, part2};
    }


    // Rough equivalent of Python re.findall for specific operand patterns
    // Handles: registers ($..), numbers (dec/hex/oct/bin), quoted chars ('..'), labels (word)
    vector<string> find_operands(const string& ops_s) {
        vector<string> ops;
        string current_token;
        char current_quote = 0; // Not in quotes

        for (size_t i = 0; i < ops_s.length(); ++i) {
            char c = ops_s[i];

            if (current_quote != 0) { // Inside quotes
                current_token += c;
                if (c == current_quote) { // End quote
                    if (current_token.length() >= 2) ops.push_back(current_token); // Store full quote
                    current_token = "";
                    current_quote = 0;
                } else if (c == '\\' && i + 1 < ops_s.length()) { // Handle escape sequence
                    current_token += ops_s[++i]; // Add escaped char
                }
            } else { // Not inside quotes
                if (c == '\'' ) { // Start quote
                    if (!current_token.empty()) ops.push_back(current_token); // Store previous token
                    current_token = c;
                    current_quote = c;
                } else if (isspace(c) || c == ',') { // Delimiter
                    if (!current_token.empty()) {
                        ops.push_back(current_token);
                        current_token = "";
                    }
                } else { // Part of a token (register, label, number)
                    current_token += c;
                }
            }
        }
        // Add the last token if any
        if (!current_token.empty()) {
            // Check if it's an unterminated quote - error?
            if (current_quote != 0) {
                cerr << "Warning: Unterminated quote in operand string: " << ops_s << endl;
            }
            ops.push_back(current_token);
        }
        return ops;
    }


    // --- Main Parsing Logic ---

    void sim_parse_program(const vector<string>& lines) {
        uint32_t data_address = DATA_BASE_ADDRESS;
        size_t instruction_index = 0; // Corresponds to index in parsed_instructions
        current_segment = ".text";

        for (size_t line_num = 0; line_num < lines.size(); ++line_num) {
            string current_line = lines[line_num];

            // Remove comments
            size_t comment_pos = current_line.find('#');
            if (comment_pos != string::npos) {
                current_line = current_line.substr(0, comment_pos);
            }

            // Basic trim
            size_t first = current_line.find_first_not_of(" \t\n\r");
            if (string::npos == first) continue;
            size_t last = current_line.find_last_not_of(" \t\n\r");
            current_line = current_line.substr(first, (last - first + 1));

            if (current_line.empty()) continue;

            // Label Handling
            string label;
            string content_after_label = current_line;
            size_t colon_pos = current_line.find(':');
            // Ensure colon is not inside quotes if we want robust label parsing
            if (colon_pos != string::npos) {
                // Simple check: label is usually alphanumeric + underscore at start
                bool likely_label = true;
                label = current_line.substr(0, colon_pos);
                // Basic trim for label itself
                size_t lbl_first = label.find_first_not_of(" \t"); if(lbl_first != string::npos) label = label.substr(lbl_first);
                size_t lbl_last = label.find_last_not_of(" \t"); if(lbl_last != string::npos) label = label.substr(0, lbl_last+1);


                for(char ch : label) {
                    if (!isalnum(ch) && ch != '_') { likely_label = false; break; }
                }
                if(label.empty() || !likely_label || label.find_first_of(" \t") != string::npos) { // Ensure no spaces in label
                    label = "";
                    content_after_label = current_line;
                } else {
                    content_after_label = current_line.substr(colon_pos + 1);
                    // Trim content after label
                    size_t content_first = content_after_label.find_first_not_of(" \t\n\r");
                    content_after_label = (string::npos == content_first) ? "" : content_after_label.substr(content_first);

                    // Store label
                    if (current_segment == ".data") {
                        data_segment[label] = data_address;
                    } else if (current_segment == ".text") {
                        uint32_t instr_address = CODE_BASE_ADDRESS + static_cast<uint32_t>(instruction_index * 4);
                        labels[label] = instr_address;
                    } // else: Warn printed if needed during segment check phase
                }
            }

            string content_to_process = content_after_label;
            if (content_to_process.empty()) continue;

            // Segment Directive Handling
            if (content_to_process == ".text") { current_segment = ".text"; continue; }
            if (content_to_process == ".data") { current_segment = ".data"; continue; }

            // Process Content Based on Segment
            if (current_segment == ".data") {
                auto [directive_name, value_str_raw] = split_string_once(content_to_process, " ");
                string directive_value_str = value_str_raw;

                try {
                    if (directive_name == ".float") {
                        if (!directive_value_str.empty()) {
                            double value_f = stod(directive_value_str);
                            int32_t int_bits = float_to_int_bits(value_f);
                            _set_mem_word(data_address, int_bits); data_address += 4;
                        } else { cerr << "Warn(l" << line_num + 1 << "): Missing .float value" << endl; }
                    } else if (directive_name == ".asciiz") {
                        // C++ equivalent: Check if directive_value_str has value, use "" otherwise.
                        // Assuming directive_value_str is std::string or similar:
                        string str_lit = directive_value_str; // Simplification: assume directive_value_str is never null/None
                        // --- START Corrected Escape Sequence Handling ---
                        // Match the quotes
                        if (str_lit.length() >= 2 && str_lit.front() == '"' && str_lit.back() == '"') {
                            // Extract the content INSIDE the quotes
                            string value_raw = str_lit.substr(1, str_lit.length() - 2); // <<<<<< INITIALIZATION
                        
                            for (size_t i = 0; i < value_raw.length(); ++i) {
                                char c = value_raw[i];
                                if (c == '\\' && i + 1 < value_raw.length()) {
                                    // Potential escape sequence
                                    i++; // Consume the backslash
                                    char next_c = value_raw[i];
                                    switch (next_c) {
                                        case 'n': _set_mem_byte(data_address++, '\n'); break; // Store actual newline
                                        case 't': _set_mem_byte(data_address++, '\t'); break; // Store actual tab
                                        case '0': _set_mem_byte(data_address++, '\0'); break; // Allow embedding null char
                                        case '\\': _set_mem_byte(data_address++, '\\'); break; // Store literal backslash
                                        case '"': _set_mem_byte(data_address++, '"'); break; // Store literal double quote
                                        case '\'': _set_mem_byte(data_address++, '\''); break; // Store literal single quote
                                        // Add other common C/MIPS escapes if needed (e.g., \r, \f, \b)
                                        default:
                                            // Unknown escape sequence: Store backslash and the character literally
                                            _set_mem_byte(data_address++, '\\');
                                            _set_mem_byte(data_address++, static_cast<uint8_t>(next_c));
                                            cerr << "Warn (line " << line_num+1 << "): Unknown escape sequence '\\" << next_c << "' in .asciiz" << endl;
                                            break;
                                    }
                                } else {
                                    // Regular character (not a backslash or last char is a backslash)
                                    _set_mem_byte(data_address++, static_cast<uint8_t>(c));
                                }
                            }
                            // --- END Corrected Escape Sequence Handling ---

                            _set_mem_byte(data_address++, 0); // Null terminator AFTER processing string content

                            // Align data address to next word boundary
                            while (data_address % 4 != 0) {
                                _set_mem_byte(data_address++, 0);
                            }

                        } else {
                            cerr << "Warn (line " << line_num+1 << "): Invalid .asciiz format: " << str_lit << endl;
                        }

                    } else if (directive_name == ".word") {
                        if (!directive_value_str.empty()) {
                            int32_t value_i = _parse_immediate(directive_value_str, ".word");
                            _set_mem_word(data_address, value_i); data_address += 4;
                        } else { cerr << "Warn(l" << line_num + 1 << "): Missing .word value" << endl; }
                    } else if (directive_name == ".space") {
                        if (!directive_value_str.empty()) {
                            int size = stoi(directive_value_str);
                            if (size < 0) throw runtime_error("Negative size");
                            data_address += size; // Conceptual allocation
                        } else { cerr << "Warn(l" << line_num + 1 << "): Missing .space value" << endl; }
                    } else if (directive_name == ".byte") {
                        if (!directive_value_str.empty()) {
                            int32_t value_i = _parse_immediate(directive_value_str, ".byte");
                            _set_mem_byte(data_address++, static_cast<uint8_t>(value_i & 0xFF));
                        } else { cerr << "Warn(l" << line_num + 1 << "): Missing .byte value" << endl; }
                    } else if (directive_name == ".align") {
                        if (!directive_value_str.empty()) {
                            int align_val = stoi(directive_value_str);
                            if (align_val < 0) throw runtime_error("Negative align");
                            uint32_t align_bytes = 1 << align_val;
                            uint32_t mask = align_bytes - 1;
                            uint32_t rem = data_address & mask;
                            if (rem != 0) data_address += (align_bytes - rem); // Conceptual
                        } else { cerr << "Warn(l" << line_num + 1 << "): Missing .align value" << endl; }
                    } else {
                        cerr << "Warn(l" << line_num + 1 << "): Unknown directive '" << directive_name << "'" << endl;
                    }
                } catch (const exception& e) {
                    cerr << "Error parsing data directive at line " << line_num + 1 << " ('" << content_to_process << "'): " << e.what() << endl;
                }

            } else if (current_segment == ".text") {
                vector<string> instructions_on_line = split_string(content_to_process, ';');
                for (const string& instruction_str_raw : instructions_on_line) {
                    // Trim individual instruction part
                    size_t instr_first = instruction_str_raw.find_first_not_of(" \t");
                    if (instr_first == string::npos) continue;
                    size_t instr_last = instruction_str_raw.find_last_not_of(" \t");
                    string instruction_str = instruction_str_raw.substr(instr_first, (instr_last - instr_first + 1));


                    instruction_strings.push_back(instruction_str);

                    auto [op_str, ops_s] = split_string_once(instruction_str, " ");
                    vector<string> ops_list = find_operands(ops_s);

                    int opcode_id = OP_UNKNOWN;
                    auto it = OPCODE_STR_TO_ID.find(op_str);
                    if (it != OPCODE_STR_TO_ID.end()) opcode_id = it->second;
                    else cerr << "Warn(l" << line_num + 1 << "): Unknown instruction mnemonic '" << op_str << "'" << endl;

                    parsed_instructions.emplace_back(opcode_id, ops_list);
                    instruction_index++;
                }
            }
        }

        heap_pointer = data_address;
        size_t num_parsed = parsed_instructions.size();
        cout << "Program loaded. " << num_parsed << " instructions parsed. Data ends 0x"
            << hex << data_address << ", Heap starts 0x" << hex << heap_pointer << dec << endl;
    }

    void sim_load_program(const string& filename) {
        sim_initialize();
        ifstream infile(filename);
        if (!infile) {
            throw runtime_error("Could not open assembly file: " + filename);
        }
        vector<string> lines;
        string line;
        while (getline(infile, line)) {
            // Handle potential CRLF line endings if needed
            if (!line.empty() && line.back() == '\r') {
                line.pop_back();
            }
            lines.push_back(line);
        }
        infile.close();
        sim_parse_program(lines);
    }

// === END SECTION 6 ===

// --- Unit Test for Section 6 ---
    // Helper to create temporary file for testing load/parse
    bool write_temp_file(const string& filename, const string& content) {
        ofstream outfile(filename);
        if (!outfile) return false;
        outfile << content;
        return outfile.good();
    }

    void test_load_parse() {
        cout << "Testing Load & Parse..." << endl;
        const string test_file_name = "temp_test_asm.s";
        const string asm_content = R"(
    .data
    label1: .word 123
    label2: .asciiz "Hello\n"
    f_val:  .float 3.14
    .text
    main:
        li $v0, 5      # Read int syscall code
        syscall        # Make the call
        add $a0, $v0, $zero # Move result to $a0
        li $v0, 1      # Print int syscall code
        syscall        # Print the int
        j end_prog     # Jump to end

    # Another instruction
        lw $t0, label1($zero) # Load word from data segment

    end_prog:
        li $v0, 10     # Exit syscall
        syscall
    )";

        if (!write_temp_file(test_file_name, asm_content)) {
            cerr << "Failed to write temporary file for parsing test." << endl;
            assert(false);
            return;
        }

        // Run load and parse
        sim_load_program(test_file_name); // Calls initialize and parse

        // Check parser output
        assert(labels.count("main"));
        assert(labels["main"] == CODE_BASE_ADDRESS); // First instruction
        assert(labels.count("end_prog"));
        assert(labels["end_prog"] == CODE_BASE_ADDRESS + 7 * 4); // After 6 instructions

        assert(data_segment.count("label1"));
        assert(data_segment["label1"] == DATA_BASE_ADDRESS); // First data item
        assert(data_segment.count("label2"));
        assert(data_segment["label2"] == DATA_BASE_ADDRESS + 4); // After first word
        assert(data_segment.count("f_val"));
        assert(data_segment["f_val"] == DATA_BASE_ADDRESS + 4 + 8); // After word and aligned string ("Hello\n\0" -> 7 bytes + 1 pad = 8)


        // Check memory content
        assert(_get_mem_word(DATA_BASE_ADDRESS) == 123); // label1
        assert(_get_mem_byte(DATA_BASE_ADDRESS + 4) == 'H'); // label2 start
        assert(_get_mem_byte(DATA_BASE_ADDRESS + 9) == '\n');
        assert(_get_mem_byte(DATA_BASE_ADDRESS + 10) == 0); // Null terminator
        assert(_get_mem_byte(DATA_BASE_ADDRESS + 11) == 0); // Padding
        int32_t float_bits = _get_mem_word(DATA_BASE_ADDRESS + 12); // f_val (after aligned string)
        assert(abs(int_bits_to_float(float_bits) - 3.14) < 1e-6);


        // Check parsed instructions
        assert(parsed_instructions.size() == 9); // 8 instructions total
        assert(parsed_instructions[0].first == OP_LI); // li $v0, 5
        assert(parsed_instructions[0].second.size() == 2);
        assert(parsed_instructions[0].second[0] == "$v0");
        assert(parsed_instructions[0].second[1] == "5");
        assert(parsed_instructions[1].first == OP_SYSCALL); // syscall
        assert(parsed_instructions[2].first == OP_ADD); // add $a0, $v0, $zero
        assert(parsed_instructions[3].first == OP_LI); // li $v0, 1
        assert(parsed_instructions[4].first == OP_SYSCALL); // syscall
        assert(parsed_instructions[5].first == OP_J); // j end_prog
        assert(parsed_instructions[6].first == OP_LW); // lw $t0, label1($zero)
        assert(parsed_instructions[7].first == OP_LI); // li $v0, 10 (at end_prog)


        // Clean up
        remove(test_file_name.c_str());

        cout << "Load & Parse Test Passed." << endl;
    }
// --- End Unit Test ---

// === SECTION 7: Quantum Helpers ===

    // Uses std::complex norm (magnitude squared)
    double _calculate_magnitude_sq(complex<double> c) {
        return norm(c);
    }

    // Forward declaration needed by handlers if defined later
    void _apply_single_qubit_gate(const GateMatrix& gate, int qubit_idx);
    int _get_qubit_index_from_reg(const string& reg_name); // Also needed

    // Gate application logic
    void _apply_single_qubit_gate(const GateMatrix& gate, int qubit_idx) {
        // Input validation
        if (gate.size() != 2 || gate[0].size() != 2 || gate[1].size() != 2) {
            throw runtime_error("Invalid gate matrix dimensions for single qubit gate.");
        }
        if (qubit_idx < 0 || qubit_idx >= NUM_QUBITS) {
            throw runtime_error("Qubit index out of range in _apply_single_qubit_gate.");
        }

        QuantumState new_state(STATE_SIZE, complex<double>(0.0, 0.0));
        uint32_t mask = 1 << qubit_idx;
        complex<double> g00 = gate[0][0], g01 = gate[0][1];
        complex<double> g10 = gate[1][0], g11 = gate[1][1];

        // Optimized loop structure (iterating pairs)
        for (size_t i = 0; i < STATE_SIZE; ++i) {
            // Check if the current index i corresponds to the '0' state for the target qubit
            if ((i & mask) == 0) {
                size_t i0 = i;
                size_t i1 = i | mask; // Index with the target qubit flipped to '1'

                // Bounds check (shouldn't be strictly necessary if STATE_SIZE is correct power of 2)
                if (i0 < STATE_SIZE && i1 < STATE_SIZE) {
                    complex<double> a0 = quantum_state[i0];
                    complex<double> a1 = quantum_state[i1];

                    new_state[i0] = g00 * a0 + g01 * a1;
                    new_state[i1] = g10 * a0 + g11 * a1;
                } else {
                    // This case indicates a logic error or incorrect STATE_SIZE
                    cerr << "Warning: Index out of bounds in _apply_single_qubit_gate loop." << endl;
                }
            }
            // If (i & mask) != 0, the state was handled when processing i0 = i & (~mask)
        }

        // Use std::move for potential efficiency
        quantum_state = move(new_state);
    }

    void _apply_cnot_gate(int control_idx, int target_idx) {
        if (control_idx == target_idx || control_idx < 0 || control_idx >= NUM_QUBITS ||
            target_idx < 0 || target_idx >= NUM_QUBITS) {
            throw runtime_error("Invalid CNOT control/target qubits.");
        }

        uint32_t control_mask = 1 << control_idx;
        uint32_t target_mask = 1 << target_idx;

        // Optimized loop: Iterate only through states where control is 1, process pairs once
        for (size_t i = 0; i < STATE_SIZE; ++i) {
            if ((i & control_mask) != 0) { // Check if control bit is 1
                size_t j = i ^ target_mask; // Calculate index with target bit flipped
                // Ensure we only swap each pair once using the i < j trick
                if (i < j) {
                    swap(quantum_state[i], quantum_state[j]);
                }
            }
        }
    }

    int _get_qubit_index_from_reg(const string& reg_name) {
        int32_t val = _get_register_value(reg_name);
        int qubit_index = static_cast<int>(val);

        if (qubit_index < 0 || qubit_index >= NUM_QUBITS) {
            throw runtime_error("Qubit index " + to_string(qubit_index) +
                                " out of range (0-" + to_string(NUM_QUBITS - 1) + ")");
        }
        return qubit_index;
    }

    // --- Add RNG needed for measure/reset ---
    #include <random> // Make sure this include is present at the top (Section 1)

    // Global RNG (Consider seeding properly if reproducible results are needed)
    mt19937 rng(random_device{}()); // Mersenne Twister
    uniform_real_distribution<double> dist(0.0, 1.0); // Distribution for [0.0, 1.0)

    bool sim_measure(const vector<string>& operands) {
        if (operands.size() != 1) throw runtime_error("measure expects 1 operand");
        int qubit_idx = _get_qubit_index_from_reg(operands[0]);
        uint32_t mask = 1 << qubit_idx;
        double prob0 = 0.0;

        // Calculate probability of measuring |0>
        for (size_t i = 0; i < STATE_SIZE; ++i) {
            if ((i & mask) == 0) { // If state has 0 at qubit_idx
                prob0 += norm(quantum_state[i]); // norm is |amp|^2
            }
        }

        // Normalize state if necessary (optional, but good practice)
        double total_prob_sq = 0.0;
        for(const auto& amp : quantum_state) total_prob_sq += norm(amp);

        // Use a slightly larger tolerance for checking if normalization is needed
        if (abs(total_prob_sq - 1.0) > 1e-9) {
            // Check if state is non-zero before trying to normalize
            if (total_prob_sq > 1e-15) { // Use a very small threshold > 0
                double renorm_factor = sqrt(total_prob_sq);
                for(auto& amp : quantum_state) amp /= renorm_factor;
                prob0 /= total_prob_sq; // Renormalize prob0 as well
            } else {
                // State is essentially zero, measurement is undefined/problematic
                // Set to a default state, e.g., |0...0> with prob0 = 1.0? Or throw?
                // Let's follow Python's apparent behavior (collapse to zero state)
                // but set prob0=1.0 to avoid division by zero.
                prob0 = 1.0;
                cerr << "Warning: Measuring near-zero quantum state." << endl;
                // quantum_state is effectively zero already if total_prob_sq is tiny.
            }
        }
        // Ensure probability is valid after potential renormalization
        prob0 = clamp(prob0, 0.0, 1.0);
        double prob1 = 1.0 - prob0;

        // Perform measurement
        double rand_num = dist(rng); // Get random number [0.0, 1.0)
        int outcome = (rand_num < prob0) ? 0 : 1;

        // Collapse state
        QuantumState new_state(STATE_SIZE, complex<double>(0.0, 0.0));
        double norm_sq_after_collapse = (outcome == 0) ? prob0 : prob1;

        // Use a small threshold to avoid division by tiny numbers
        if (norm_sq_after_collapse > 1e-15) {
            double norm_factor = sqrt(norm_sq_after_collapse);
            for (size_t i = 0; i < STATE_SIZE; ++i) {
                // Check if state 'i' matches the outcome at the measured qubit
                if (((i >> qubit_idx) & 1) == outcome) {
                    new_state[i] = quantum_state[i] / norm_factor;
                }
            }
            quantum_state = move(new_state);
        } else {
            // State collapsed entirely to zero for the measured outcome
            quantum_state.assign(STATE_SIZE, complex<double>(0.0, 0.0)); // Assign zero state
        }

        _set_register_value("$s9", static_cast<int32_t>(outcome)); // Store outcome
        return false; // No branch
    }

    bool sim_reset(const vector<string>& operands) {
        if (operands.size() != 1) throw runtime_error("reset expects 1 operand");
        int qubit_idx = _get_qubit_index_from_reg(operands[0]);
        uint32_t mask = 1 << qubit_idx;
        double prob0 = 0.0;

        // Calculate probability of measuring |0>
        for (size_t i = 0; i < STATE_SIZE; ++i) {
            if ((i & mask) == 0) {
                prob0 += norm(quantum_state[i]);
            }
        }

        // Normalize state if necessary
        double total_prob_sq = 0.0;
        for(const auto& amp : quantum_state) total_prob_sq += norm(amp);
        if (abs(total_prob_sq - 1.0) > 1e-9) {
            if (total_prob_sq > 1e-15) {
                double renorm_factor = sqrt(total_prob_sq);
                for(auto& amp : quantum_state) amp /= renorm_factor;
                prob0 /= total_prob_sq;
            } else {
                prob0 = 1.0; // Treat zero state as measuring 0 with prob 1
                cerr << "Warning: Resetting near-zero quantum state." << endl;
            }
        }
        prob0 = clamp(prob0, 0.0, 1.0);
        double prob1 = 1.0 - prob0;

        // Perform measurement (simulated)
        double rand_num = dist(rng);
        int outcome = (rand_num < prob0) ? 0 : 1;

        // Collapse state
        QuantumState new_state(STATE_SIZE, complex<double>(0.0, 0.0));
        double norm_sq_after_collapse = (outcome == 0) ? prob0 : prob1;

        if (norm_sq_after_collapse > 1e-15) {
            double norm_factor = sqrt(norm_sq_after_collapse);
            for (size_t i = 0; i < STATE_SIZE; ++i) {
                if (((i >> qubit_idx) & 1) == outcome) {
                    new_state[i] = quantum_state[i] / norm_factor;
                }
            }
            quantum_state = move(new_state);
        } else {
            quantum_state.assign(STATE_SIZE, complex<double>(0.0, 0.0));
        }

        // If outcome was 1, apply X gate to flip back to |0>
        if (outcome == 1) {
            // Ensure state is valid before applying gate (it might be zero if prob1 was tiny)
            // Recalculate norm after potential collapse to zero
            double current_norm_sq = 0.0;
            for(const auto& amp : quantum_state) current_norm_sq += norm(amp);
            if (current_norm_sq > 1e-15) { // Only apply X if state is non-zero
                _apply_single_qubit_gate(X_GATE, qubit_idx);
            } else {
                // If state was zero, applying X still results in zero state
                // Or, arguably, reset should force |0> state regardless.
                // Let's force |0> state if outcome was 1 but state became zero.
                quantum_state.assign(STATE_SIZE, complex<double>(0.0, 0.0));
                quantum_state[0] = complex<double>(1.0, 0.0); // Force |0...0>
                // Need to ensure the measured qubit index is 0 for this simple assignment.
                // More robustly: find the index `idx_0` where only bit `qubit_idx` is 0, set that to 1.
                // Find index where all bits are 0: index is 0.
                // Find index where only measured qubit bit is 1: index is `1 << qubit_idx`.
                // If outcome was 1 and state collapsed to 0, conceptually it should be |1> at that qubit.
                // Applying X flips it to |0>. So forcing state[0] = 1.0 is correct for |0...0>.
            }
        }
        // If outcome was 0, the state is already collapsed to subspace where qubit is |0>.

        return false;
    }

// === END SECTION 7 ===


// --- Unit Test for Section 7 ---
    void test_quantum_helpers() {
        cout << "Testing Quantum Helpers..." << endl;
        sim_initialize(); // Sets state to |00...0>

        // Test _calculate_magnitude_sq
        complex<double> c1(3.0, 4.0);
        assert(abs(_calculate_magnitude_sq(c1) - 25.0) < 1e-9);

        // Test _get_qubit_index_from_reg
        _set_register_value("$t0", 2);
        assert(_get_qubit_index_from_reg("$t0") == 2);
        bool caught_oor_qi = false;
        try { _set_register_value("$t1", NUM_QUBITS); _get_qubit_index_from_reg("$t1"); }
        catch(const runtime_error&) { caught_oor_qi = true; }
        assert(caught_oor_qi);

        // Test _apply_single_qubit_gate (Hadamard on |0>)
        // State is |00000> initially
        _apply_single_qubit_gate(H_GATE, 0); // Apply H to qubit 0
        // Expected state: 1/sqrt(2) * (|00000> + |00001>) if NUM_QUBITS=5
        // Indices 0 and 1 should have non-zero amplitude
        assert(abs(norm(quantum_state[0]) - 0.5) < 1e-9);
        assert(abs(norm(quantum_state[1]) - 0.5) < 1e-9);
        if (STATE_SIZE > 2) assert(abs(norm(quantum_state[2])) < 1e-9); // Others should be zero
        assert(abs(quantum_state[0].real() - _SQRT2_INV) < 1e-9);
        assert(abs(quantum_state[1].real() - _SQRT2_INV) < 1e-9);

        // Apply H again to qubit 0, should return to |00000>
        _apply_single_qubit_gate(H_GATE, 0);
        assert(abs(norm(quantum_state[0]) - 1.0) < 1e-9); // Back to |0> state
        if (STATE_SIZE > 1) assert(abs(norm(quantum_state[1])) < 1e-9);

        // Test _apply_cnot_gate
        // Create Bell state 1/sqrt(2)(|00> + |11>) for first 2 qubits (assume NUM_QUBITS >= 2)
        _apply_single_qubit_gate(H_GATE, 0); // 1/sqrt(2)(|00> + |01>) (rest are |0>)
        _apply_cnot_gate(0, 1);             // Control=0, Target=1
        // Expected state: 1/sqrt(2) * (|00000> + |00011>) (indices 0 and 3 for 5 qubits)
        assert(abs(norm(quantum_state[0]) - 0.5) < 1e-9); // |00000>
        uint32_t idx_11 = 3; // Binary 00011
        assert(abs(norm(quantum_state[idx_11]) - 0.5) < 1e-9); // |00011>
        // Check a few others are zero
        assert(abs(norm(quantum_state[1])) < 1e-9);
        assert(abs(norm(quantum_state[2])) < 1e-9);

        cout << "Quantum Helpers Test Passed." << endl;
    }
// --- End Unit Test ---


// === SECTION 8: Instruction Handlers ===

    // --- Quantum Handlers ---
    bool sim_h(const vector<string>& operands) {
        if (operands.size() != 1) throw runtime_error("H expects 1 operand");
        int idx = _get_qubit_index_from_reg(operands[0]);
        _apply_single_qubit_gate(H_GATE, idx);
        return false; // No branch
    }

    bool sim_x(const vector<string>& operands) {
        if (operands.size() != 1) throw runtime_error("X expects 1 operand");
        int idx = _get_qubit_index_from_reg(operands[0]);
        _apply_single_qubit_gate(X_GATE, idx);
        return false;
    }

    bool sim_cnot(const vector<string>& operands) {
        if (operands.size() != 2) throw runtime_error("CNOT expects 2 operands");
        int target_idx = _get_qubit_index_from_reg(operands[0]);
        int control_idx = _get_qubit_index_from_reg(operands[1]);
        _apply_cnot_gate(control_idx, target_idx);
        return false;
    }

    // --- Classical Handlers (Complete Set) ---
    bool sim_add(const vector<string>& operands) {
        if (operands.size() != 3) throw runtime_error("ADD expects 3 operands");
        _set_register_value(operands[0],
            _get_register_value(operands[1]) + _get_register_value(operands[2]));
        return false;
    }

    bool sim_sub(const vector<string>& operands) {
        if (operands.size() != 3) throw runtime_error("SUB expects 3 operands");
        _set_register_value(operands[0],
            _get_register_value(operands[1]) - _get_register_value(operands[2]));
        return false;
    }

    bool sim_addi(const vector<string>& operands) {
        if (operands.size() != 3) throw runtime_error("ADDI expects 3 operands");
        try {
            int32_t imm_full = _parse_immediate(operands[2], "ADDI");
            int16_t imm_16 = static_cast<int16_t>(imm_full & 0xFFFF);
            int32_t imm_s = static_cast<int32_t>(imm_16); // Sign-extend
            int32_t val1 = _get_register_value(operands[1]);
            _set_register_value(operands[0], val1 + imm_s);
        } catch (const exception& e) {
            throw runtime_error("In ADDI '" + operands[2] + "': " + e.what());
        }
        return false;
    }

    bool sim_and(const vector<string>& operands) {
        if (operands.size() != 3) throw runtime_error("AND expects 3 operands");
        _set_register_value(operands[0],
            _get_register_value(operands[1]) & _get_register_value(operands[2]));
        return false;
    }

    bool sim_or(const vector<string>& operands) {
        if (operands.size() != 3) throw runtime_error("OR expects 3 operands");
        _set_register_value(operands[0],
            _get_register_value(operands[1]) | _get_register_value(operands[2]));
        return false;
    }

    bool sim_nor(const vector<string>& operands) {
        if (operands.size() != 3) throw runtime_error("NOR expects 3 operands");
        _set_register_value(operands[0],
            ~(_get_register_value(operands[1]) | _get_register_value(operands[2])));
        return false;
    }

    bool sim_ori(const vector<string>& operands) {
        if (operands.size() != 3) throw runtime_error("ORI expects 3 operands");
        try {
            int32_t imm_full = _parse_immediate(operands[2], "ORI");
            uint32_t imm_u = static_cast<uint32_t>(imm_full & 0xFFFF); // Zero-extend
            uint32_t val1_u = static_cast<uint32_t>(_get_register_value(operands[1]));
            _set_register_value(operands[0], static_cast<int32_t>(val1_u | imm_u));
        } catch (const exception& e) {
            throw runtime_error("In ORI '" + operands[2] + "': " + e.what());
        }
        return false;
    }

    bool sim_andi(const vector<string>& operands) {
        if (operands.size() != 3) throw runtime_error("ANDI expects 3 operands");
        try {
            int32_t imm_full = _parse_immediate(operands[2], "ANDI");
            uint32_t imm_u = static_cast<uint32_t>(imm_full & 0xFFFF); // Zero-extend
            uint32_t val1_u = static_cast<uint32_t>(_get_register_value(operands[1]));
            _set_register_value(operands[0], static_cast<int32_t>(val1_u & imm_u));
        } catch (const exception& e) {
            throw runtime_error("In ANDI '" + operands[2] + "': " + e.what());
        }
        return false;
    }

    bool sim_xori(const vector<string>& operands) {
        if (operands.size() != 3) throw runtime_error("XORI expects 3 operands");
        try {
            int32_t imm_full = _parse_immediate(operands[2], "XORI");
            uint32_t imm_u = static_cast<uint32_t>(imm_full & 0xFFFF); // Zero-extend
            uint32_t val1_u = static_cast<uint32_t>(_get_register_value(operands[1]));
            _set_register_value(operands[0], static_cast<int32_t>(val1_u ^ imm_u));
        } catch (const exception& e) {
            throw runtime_error("In XORI '" + operands[2] + "': " + e.what());
        }
        return false;
    }

    bool sim_lw(const vector<string>& operands) {
        if (operands.size() != 2) throw runtime_error("LW expects 2 operands");
        auto [offset, base_reg] = _parse_offset_register(operands[1]);
        uint32_t base_addr = static_cast<uint32_t>(_get_register_value(base_reg));
        uint32_t eff_addr = base_addr + offset;
        _set_register_value(operands[0], _get_mem_word(eff_addr));
        return false;
    }

    bool sim_sw(const vector<string>& operands) {
        if (operands.size() != 2) throw runtime_error("SW expects 2 operands");
        auto [offset, base_reg] = _parse_offset_register(operands[1]);
        int32_t val = _get_register_value(operands[0]);
        uint32_t base_addr = static_cast<uint32_t>(_get_register_value(base_reg));
        uint32_t eff_addr = base_addr + offset;
        _set_mem_word(eff_addr, val);
        return false;
    }

    bool sim_lb(const vector<string>& operands) {
        if (operands.size() != 2) throw runtime_error("LB expects 2 operands");
        auto [offset, base_reg] = _parse_offset_register(operands[1]);
        uint32_t base_addr = static_cast<uint32_t>(_get_register_value(base_reg));
        uint32_t eff_addr = base_addr + offset;
        uint8_t byte_u = _get_mem_byte(eff_addr);
        // Sign-extend the byte
        int8_t byte_s = static_cast<int8_t>(byte_u);
        _set_register_value(operands[0], static_cast<int32_t>(byte_s));
        return false;
    }

    bool sim_sb(const vector<string>& operands) {
        if (operands.size() != 2) throw runtime_error("SB expects 2 operands");
        auto [offset, base_reg] = _parse_offset_register(operands[1]);
        int32_t val = _get_register_value(operands[0]);
        uint8_t byte = static_cast<uint8_t>(val & 0xFF);
        uint32_t base_addr = static_cast<uint32_t>(_get_register_value(base_reg));
        uint32_t eff_addr = base_addr + offset;
        _set_mem_byte(eff_addr, byte);
        return false;
    }

    bool sim_la(const vector<string>& operands) {
        if (operands.size() != 2) throw runtime_error("LA expects 2 operands");
        const string& dest = operands[0];
        const string& lbl = operands[1];
        uint32_t addr = 0;
        bool found = false;
        auto it_data = data_segment.find(lbl);
        if (it_data != data_segment.end()) {
            addr = it_data->second;
            found = true;
        } else {
            auto it_label = labels.find(lbl);
            if (it_label != labels.end()) {
                addr = it_label->second;
                found = true;
            }
        }
        if (!found) {
            throw runtime_error("LA label '" + lbl + "' not found");
        }
        _set_register_value(dest, static_cast<int32_t>(addr));
        return false;
    }

    bool sim_li(const vector<string>& operands) {
        if (operands.size() != 2) throw runtime_error("LI expects 2 operands");
        try {
            _set_register_value(operands[0], _parse_immediate(operands[1], "LI"));
        } catch (const exception& e) {
            throw runtime_error("In LI '" + operands[1] + "': " + e.what());
        }
        return false;
    }

    bool sim_beq(const vector<string>& operands) {
        if (operands.size() != 3) throw runtime_error("BEQ expects 3 operands");
        int32_t v1 = _get_register_value(operands[0]);
        int32_t v2 = _get_register_value(operands[1]);
        if (v1 == v2) {
            auto it = labels.find(operands[2]);
            if (it != labels.end()) { pc = it->second; return true; }
            else { throw runtime_error("BEQ label '" + operands[2] + "' not found"); }
        }
        return false;
    }

    bool sim_bne(const vector<string>& operands) {
        if (operands.size() != 3) throw runtime_error("BNE expects 3 operands");
        int32_t v1 = _get_register_value(operands[0]);
        int32_t v2 = _get_register_value(operands[1]);
        if (v1 != v2) {
            auto it = labels.find(operands[2]);
            if (it != labels.end()) { pc = it->second; return true; }
            else { throw runtime_error("BNE label '" + operands[2] + "' not found"); }
        }
        return false;
    }

    bool sim_j(const vector<string>& operands) {
        if (operands.size() != 1) throw runtime_error("J expects 1 operand");
        auto it = labels.find(operands[0]);
        if (it != labels.end()) { pc = it->second; return true; }
        else { throw runtime_error("J label '" + operands[0] + "' not found"); }
    }

    bool sim_jal(const vector<string>& operands) {
        if (operands.size() != 1) throw runtime_error("JAL expects 1 operand");
        _set_register_value("$ra", static_cast<int32_t>(pc + 4)); // Store return address
        auto it = labels.find(operands[0]);
        if (it != labels.end()) { pc = it->second; return true; }
        else { throw runtime_error("JAL label '" + operands[0] + "' not found"); }
    }

    bool sim_jr(const vector<string>& operands) {
        if (operands.size() != 1) throw runtime_error("JR expects 1 operand");
        uint32_t addr = static_cast<uint32_t>(_get_register_value(operands[0]));
        if (addr % 4 != 0) throw runtime_error("JR addr 0x" + to_string(addr) + " misaligned.");
        // Optional: Add range check against CODE segment? Not done in Python.
        pc = addr; return true;
    }

    bool sim_slt(const vector<string>& operands) {
        if (operands.size() != 3) throw runtime_error("SLT expects 3 operands");
        int32_t v1 = _get_register_value(operands[1]);
        int32_t v2 = _get_register_value(operands[2]);
        _set_register_value(operands[0], (v1 < v2) ? 1 : 0);
        return false;
    }

    bool sim_sgt(const vector<string>& operands) { // Pseudo-instruction
        if (operands.size() != 3) throw runtime_error("SGT expects 3 operands");
        int32_t v1 = _get_register_value(operands[1]);
        int32_t v2 = _get_register_value(operands[2]);
        // Implement as slt $dest, $src2, $src1
        _set_register_value(operands[0], (v2 < v1) ? 1 : 0);
        return false;
    }

    bool sim_sll(const vector<string>& operands) {
        if (operands.size() != 3) throw runtime_error("SLL expects 3 operands");
        try {
            int32_t shamt_full = _parse_immediate(operands[2], "SLL");
            uint32_t shamt = static_cast<uint32_t>(shamt_full & 0x1F); // Lower 5 bits
            int32_t val = _get_register_value(operands[1]);
            _set_register_value(operands[0], val << shamt);
        } catch (const exception& e) {
            throw runtime_error("In SLL '" + operands[2] + "': " + e.what());
        }
        return false;
    }

    bool sim_srl(const vector<string>& operands) {
        if (operands.size() != 3) throw runtime_error("SRL expects 3 operands");
        try {
            int32_t shamt_full = _parse_immediate(operands[2], "SRL");
            uint32_t shamt = static_cast<uint32_t>(shamt_full & 0x1F);
            // Logical shift right requires unsigned type
            uint32_t val_u = static_cast<uint32_t>(_get_register_value(operands[1]));
            _set_register_value(operands[0], static_cast<int32_t>(val_u >> shamt));
        } catch (const exception& e) {
            throw runtime_error("In SRL '" + operands[2] + "': " + e.what());
        }
        return false;
    }

    bool sim_sllv(const vector<string>& operands) {
        if (operands.size() != 3) throw runtime_error("SLLV expects 3 operands");
        int32_t val = _get_register_value(operands[1]);
        int32_t shamt_reg_val = _get_register_value(operands[2]);
        uint32_t shamt = static_cast<uint32_t>(shamt_reg_val & 0x1F); // Lower 5 bits
        _set_register_value(operands[0], val << shamt);
        return false;
    }

    bool sim_srlv(const vector<string>& operands) {
        if (operands.size() != 3) throw runtime_error("SRLV expects 3 operands");
        uint32_t val_u = static_cast<uint32_t>(_get_register_value(operands[1]));
        int32_t shamt_reg_val = _get_register_value(operands[2]);
        uint32_t shamt = static_cast<uint32_t>(shamt_reg_val & 0x1F);
        _set_register_value(operands[0], static_cast<int32_t>(val_u >> shamt));
        return false;
    }

    bool sim_move(const vector<string>& operands) {
        if (operands.size() != 2) throw runtime_error("MOVE expects 2 operands");
        _set_register_value(operands[0], _get_register_value(operands[1]));
        return false;
    }

    bool sim_mult(const vector<string>& operands) {
        if (operands.size() != 2) throw runtime_error("MULT expects 2 operands");
        int64_t op1 = static_cast<int64_t>(_get_register_value(operands[0])); // Use 64-bit for product
        int64_t op2 = static_cast<int64_t>(_get_register_value(operands[1]));
        int64_t res64 = op1 * op2;
        reg_hi = static_cast<int32_t>((res64 >> 32) & 0xFFFFFFFF); // Upper 32 bits
        reg_lo = static_cast<int32_t>(res64 & 0xFFFFFFFF);        // Lower 32 bits
        return false;
    }

    bool sim_mflo(const vector<string>& operands) {
        if (operands.size() != 1) throw runtime_error("MFLO expects 1 operand");
        _set_register_value(operands[0], reg_lo);
        return false;
    }

    bool sim_mfhi(const vector<string>& operands) {
        if (operands.size() != 1) throw runtime_error("MFHI expects 1 operand");
        _set_register_value(operands[0], reg_hi);
        return false;
    }

    bool sim_mtc1(const vector<string>& operands) {
        if (operands.size() != 2) throw runtime_error("MTC1 expects 2 operands");
        _set_register_value(operands[1], _get_register_value(operands[0])); // Direct bit move
        return false;
    }

    bool sim_mfc1(const vector<string>& operands) {
        if (operands.size() != 2) throw runtime_error("MFC1 expects 2 operands");
        _set_register_value(operands[0], _get_register_value(operands[1])); // Direct bit move
        return false;
    }

    bool sim_add_s(const vector<string>& operands) {
        if (operands.size() != 3) throw runtime_error("add.s expects 3 operands");
        double v1 = _get_float_from_fpr(operands[1]);
        double v2 = _get_float_from_fpr(operands[2]);
        _set_register_value(operands[0], float_to_int_bits(v1 + v2));
        return false;
    }

    bool sim_sub_s(const vector<string>& operands) {
        if (operands.size() != 3) throw runtime_error("sub.s expects 3 operands");
        double v1 = _get_float_from_fpr(operands[1]);
        double v2 = _get_float_from_fpr(operands[2]);
        _set_register_value(operands[0], float_to_int_bits(v1 - v2));
        return false;
    }

    bool sim_mul_s(const vector<string>& operands) {
        if (operands.size() != 3) throw runtime_error("mul.s expects 3 operands");
        double v1 = _get_float_from_fpr(operands[1]);
        double v2 = _get_float_from_fpr(operands[2]);
        _set_register_value(operands[0], float_to_int_bits(v1 * v2));
        return false;
    }

    bool sim_div_s(const vector<string>& operands) {
        if (operands.size() != 3) throw runtime_error("div.s expects 3 operands");
        double dividend = _get_float_from_fpr(operands[1]);
        double divisor = _get_float_from_fpr(operands[2]);
        double res_f;
        if (abs(divisor) < _FLOAT_ZERO_TOLERANCE) {
            cerr << "Warning: PC=0x" << hex << pc << dec << ": FP division by zero!" << endl;
            if (abs(dividend) < _FLOAT_ZERO_TOLERANCE) res_f = numeric_limits<double>::quiet_NaN();
            else if (dividend > 0.0) res_f = numeric_limits<double>::infinity();
            else res_f = -numeric_limits<double>::infinity();
        } else {
            res_f = dividend / divisor;
        }
        _set_register_value(operands[0], float_to_int_bits(res_f));
        return false;
    }

    bool sim_l_s(const vector<string>& operands) {
        if (operands.size() != 2) throw runtime_error("l.s expects 2 operands");
        auto [offset, base_reg] = _parse_offset_register(operands[1]);
        uint32_t base_addr = static_cast<uint32_t>(_get_register_value(base_reg));
        uint32_t eff_addr = base_addr + offset;
        _set_register_value(operands[0], _get_mem_word(eff_addr)); // Load bits
        return false;
    }

    bool sim_s_s(const vector<string>& operands) {
        if (operands.size() != 2) throw runtime_error("s.s expects 2 operands");
        auto [offset, base_reg] = _parse_offset_register(operands[1]);
        int32_t bits = _get_register_value(operands[0]); // Get bits from FPR
        uint32_t base_addr = static_cast<uint32_t>(_get_register_value(base_reg));
        uint32_t eff_addr = base_addr + offset;
        _set_mem_word(eff_addr, bits);
        return false;
    }

    bool sim_cvt_s_w(const vector<string>& operands) {
        if (operands.size() != 2) throw runtime_error("cvt.s.w expects 2 operands");
        int32_t word_bits = _get_register_value(operands[1]); // Get integer bits from FPR
        double res_f = static_cast<double>(word_bits); // Convert integer to float/double
        _set_register_value(operands[0], float_to_int_bits(res_f)); // Store float bits
        return false;
    }

    bool sim_cvt_w_s(const vector<string>& operands) {
        if (operands.size() != 2) throw runtime_error("cvt.w.s expects 2 operands");
        double float_val = _get_float_from_fpr(operands[1]); // Get float value
        // TODO: Check MIPS rounding mode. Default C++ cast truncates towards zero.
        int32_t word_val = static_cast<int32_t>(float_val);
        _set_register_value(operands[0], word_val); // Store integer result in GPR
        return false;
    }

    bool sim_mov_s(const vector<string>& operands) {
        if (operands.size() != 2) throw runtime_error("mov.s expects 2 operands");
        _set_register_value(operands[0], _get_register_value(operands[1])); // Direct bit move
        return false;
    }

    // Syscall Handler (Part of SECTION 8)
    #if __cplusplus >= 201703L
    #include <optional> // Ensure <optional> is included at the top if using C++17+
    optional<string> sim_syscall(const vector<string>& operands) {
    #else
    #include <string> // Ensure <string> is included
    string sim_syscall(const vector<string>& operands) { // Return empty string for no signal if not C++17+
    #endif
        // Define i32 alias if not present (or use int32_t directly)
        using i32 = int32_t;
        using u32 = uint32_t;
        using u64 = uint64_t;
        using u8 = uint8_t;

        i32 v0v = _get_register_value("$v0");
        i32 a0v = _get_register_value("$a0");
        double f12f = _get_float_from_fpr("$f12"); // Assumes _get_float_from_fpr is defined

        try {
            switch(v0v) {
                case 1: // print_int
                    cout << a0v;
                    break;
                case 5: // read_int
                    {
                        int i_in;
                        if (!(cin >> i_in)) {
                            cin.clear(); // Clear error flags
                            // Ignore rest of the line to prevent issues with next input
                            cin.ignore(numeric_limits<streamsize>::max(), '\n');
                            cerr << "Syscall err: bad int input" << endl;
                            _set_register_value("$v0", 0); // Set $v0 to 0 on error? Or keep previous?
                            #if __cplusplus >= 201703L
                            return "error";
                            #else
                            return "error";
                            #endif
                        }
                        _set_register_value("$v0", static_cast<i32>(i_in));
                    }
                    break;
                case 2: // print_float
                    cout << fixed << setprecision(7) << f12f;
                    break;
                case 3: // print_double
                    cout << fixed << setprecision(15) << f12f;
                    break;
                case 6: // read_float
                    {
                        double f_in;
                        if (!(cin >> f_in)) {
                            cin.clear();
                            cin.ignore(numeric_limits<streamsize>::max(), '\n');
                            cerr << "Syscall err: bad float input" << endl;
                            _set_register_value("$f0", float_to_int_bits(0.0)); // Set $f0 to 0?
                            #if __cplusplus >= 201703L
                            return "error";
                            #else
                            return "error";
                            #endif
                        }
                        _set_register_value("$f0", float_to_int_bits(f_in));
                    }
                    break;
                case 4: // print_string
                    {
                        u32 ad = static_cast<u32>(a0v);
                        char c;
                        // Add a safety counter to prevent infinite loops on non-null-terminated strings
                        int max_chars = 4096; // Limit string length printed
                        int count = 0;
                        while (count < max_chars && (c = static_cast<char>(_get_mem_byte(ad++))) != '\0') {
                            cout << c;
                            count++;
                        }
                        if (count == max_chars && c != '\0') {
                            cerr << "\nWarning: Syscall 4 encountered potentially non-null-terminated string." << endl;
                        }
                    }
                    break;
                case 11: // print_char
                    cout << static_cast<char>(a0v & 0xFF);
                    break;
                case 12: // read_char
                    {
                        char ci;
                        cin.get(ci); // Use get() to read single char, including whitespace
                        if (cin.eof() || ci == 4) { // Check EOF or Ctrl+D (ASCII 4)
                            _set_register_value("$v0", -1);
                        } else if (cin.fail()) { // Handle other stream errors
                            cerr << "Syscall12 err: Read failed" << endl;
                            // Clear errors if needed
                            cin.clear();
                            // Maybe ignore rest of line if in error state?
                            _set_register_value("$v0", -1);
                        } else {
                            // Return ASCII value as unsigned char cast to int32
                            _set_register_value("$v0", static_cast<i32>(static_cast<u8>(ci)));
                        }
                    }
                    break;
                case 9: // sbrk
                    {
                        i32 n = a0v;
                        if (n < 0) { cerr << "Syscall Err: sbrk negative size" << endl; return "error"; }
                        u32 alc = heap_pointer;
                        u64 next_heap_ptr = static_cast<u64>(heap_pointer) + n;
                        // Check against high memory boundary
                        if (next_heap_ptr >= HEAP_META_END_ADDRESS) {
                            cerr << "Syscall Err: sbrk overflow" << endl; return "error";
                        }
                        heap_pointer = static_cast<u32>(next_heap_ptr);
                        _set_register_value("$v0", static_cast<i32>(alc)); // Return original heap pointer
                    }
                    break;
                case 10: // exit
                    #if __cplusplus >= 201703L
                    return "exit";
                    #else
                    return "exit";
                    #endif
                default:
                    cout << "Unknown syscall " << v0v << endl;
                    break;
            }
        } catch (const exception& e) {
            // Catch errors during memory access within syscall
            cerr << "Syscall " << v0v << " internal error: " << e.what() << endl;
            #if __cplusplus >= 201703L
            return "error";
            #else
            return "error";
            #endif
        }

        // Normal return if no exit/error signal
        #if __cplusplus >= 201703L
        return nullopt;
        #else
        return "";
        #endif
    }

// === END SECTION 8 ===

// --- Unit Test for Section 8 ---

    // Forward declaration for sim_syscall needed by test function
    #if __cplusplus >= 201703L
    optional<string> sim_syscall(const vector<string>& operands);
    #else
    string sim_syscall(const vector<string>& operands);
    #endif

    void test_instruction_handlers() {
        cout << "Testing Instruction Handlers..." << endl;
        sim_initialize();

        // Test ADD
        _set_register_value("$t1", 10);
        _set_register_value("$t2", 20);
        sim_add({"$t0", "$t1", "$t2"});
        assert(_get_register_value("$t0") == 30);

        // Test ADDI
        sim_addi({"$t0", "$t1", "-5"});
        assert(_get_register_value("$t0") == 5); // 10 + (-5)

        // Test LW/SW (uses memory tests indirectly)
        _set_register_value("$sp", STACK_BASE_ADDRESS); // Set stack pointer
        _set_register_value("$t3", 999);
        sim_sw({"$t3", "-4($sp)"}); // Store 999 just below stack base
        assert(_get_mem_word(STACK_BASE_ADDRESS - 4) == 999);
        sim_lw({"$t4", "-4($sp)"}); // Load it back
        assert(_get_register_value("$t4") == 999);

        // Test BEQ (branch taken)
        pc = 0x400010; // Set current PC
        labels["target"] = 0x400100;
        _set_register_value("$s0", 100);
        _set_register_value("$s1", 100);
        bool branch_taken = sim_beq({"$s0", "$s1", "target"});
        assert(branch_taken == true);
        assert(pc == 0x400100); // PC should be updated

        // Test BEQ (branch not taken)
        pc = 0x400020;
        _set_register_value("$s1", 101);
        branch_taken = sim_beq({"$s0", "$s1", "target"});
        assert(branch_taken == false);
        assert(pc == 0x400020); // PC should NOT be updated

        // Test ADD.S
        _set_register_value("$f1", float_to_int_bits(10.5));
        _set_register_value("$f2", float_to_int_bits(2.0));
        sim_add_s({"$f0", "$f1", "$f2"});
        assert(abs(_get_float_from_fpr("$f0") - 12.5) < 1e-6);

        // Test Syscall (print_int case 1 - just check no crash)
        _set_register_value("$v0", 1);
        _set_register_value("$a0", 777);
        #if __cplusplus >= 201703L
        assert(!sim_syscall({}).has_value());
        #else
        assert(sim_syscall({}).empty());
        #endif
        // Output "777" would normally appear on cout

        // Test Syscall (exit case 10)
        _set_register_value("$v0", 10);
        #if __cplusplus >= 201703L
        assert(sim_syscall({}).value_or("") == "exit");
        #else
        assert(sim_syscall({}) == "exit");
        #endif


        cout << "Instruction Handlers Test Passed (basic cases)." << endl;
    }
// --- End Unit Test ---


// === SECTION 9: sim_run ===

    // Forward declarations
    void sim_print_registers();
    void sim_print_quantum_state();
    #if __cplusplus >= 201703L
    optional<string> sim_syscall(const vector<string>& operands);
    #else
    string sim_syscall(const vector<string>& operands);
    #endif
    // Add forward declarations for ALL sim_* instruction handlers here
    // Forward declaration for sim_syscall needed by test function

    // (Example)
    bool sim_add(const vector<string>& operands);
    bool sim_sub(const vector<string>& operands);
    bool sim_addi(const vector<string>& operands);
    bool sim_and(const vector<string>& operands);
    bool sim_or(const vector<string>& operands);
    bool sim_nor(const vector<string>& operands);
    bool sim_ori(const vector<string>& operands);
    bool sim_andi(const vector<string>& operands);
    bool sim_xori(const vector<string>& operands);
    bool sim_lw(const vector<string>& operands);
    bool sim_sw(const vector<string>& operands);
    bool sim_lb(const vector<string>& operands);
    bool sim_sb(const vector<string>& operands);
    bool sim_la(const vector<string>& operands);
    bool sim_li(const vector<string>& operands);
    bool sim_beq(const vector<string>& operands);
    bool sim_bne(const vector<string>& operands);
    bool sim_j(const vector<string>& operands);
    bool sim_jal(const vector<string>& operands);
    bool sim_jr(const vector<string>& operands);
    bool sim_slt(const vector<string>& operands);
    bool sim_sgt(const vector<string>& operands);
    bool sim_sll(const vector<string>& operands);
    bool sim_srl(const vector<string>& operands);
    bool sim_sllv(const vector<string>& operands);
    bool sim_srlv(const vector<string>& operands);
    bool sim_move(const vector<string>& operands);
    bool sim_mult(const vector<string>& operands);
    bool sim_mflo(const vector<string>& operands);
    bool sim_mfhi(const vector<string>& operands);
    bool sim_mtc1(const vector<string>& operands);
    bool sim_mfc1(const vector<string>& operands);
    bool sim_add_s(const vector<string>& operands);
    bool sim_sub_s(const vector<string>& operands);
    bool sim_mul_s(const vector<string>& operands);
    bool sim_div_s(const vector<string>& operands);
    bool sim_l_s(const vector<string>& operands);
    bool sim_s_s(const vector<string>& operands);
    bool sim_cvt_s_w(const vector<string>& operands);
    bool sim_cvt_w_s(const vector<string>& operands);
    bool sim_mov_s(const vector<string>& operands);
    bool sim_h(const vector<string>& operands);
    bool sim_x(const vector<string>& operands);
    bool sim_cnot(const vector<string>& operands);
    bool sim_measure(const vector<string>& operands);
    bool sim_reset(const vector<string>& operands);

    void sim_run(bool summary = false) {
        uint32_t start_pc = CODE_BASE_ADDRESS;
        auto it_main = labels.find("main");
        if (it_main != labels.end()) {
            start_pc = it_main->second;
        } else {
            cout << "Warning: 'main' label missing, starting at CODE_BASE_ADDRESS." << endl;
        }
        pc = start_pc;

        map<int, uint64_t> IC;
        uint64_t count = 0;
        const uint64_t limit = 2000000;

        cout << "\nStarting execution...\n" << endl;

        size_t num_parsed_instr = parsed_instructions.size();
        uint32_t max_pc = CODE_BASE_ADDRESS + static_cast<uint32_t>(num_parsed_instr * 4);

        while (true) {
            // --- Termination Checks ---
            if (pc < CODE_BASE_ADDRESS || pc >= max_pc) {
                bool is_normal_end = (pc == max_pc);
                // Use stringstream for cleaner hex output integration
                stringstream ss_pc_msg;
                ss_pc_msg << (is_normal_end ? "\nExecution finished normally." : "\nPC 0x" + string(8 - to_string(pc).length(), '0') + to_string(pc) + " out of text segment bounds.");
                cout << ss_pc_msg.str() << endl;
                break;
            }
            // // Disable instruction limit for now
            // if (count >= limit) {
            //     cout << "\nInstruction limit (" << limit << ") reached." << endl;
            //     break;
            // }
            uint32_t current_offset = pc - CODE_BASE_ADDRESS;
            if (current_offset % 4 != 0) {
                cout << "\nPC " << hex << pc << dec << " is misaligned!" << endl;
                break;
            }

            // --- Fetch (from parsed list) ---
            size_t idx = current_offset / 4;
            int opcode_id = OP_UNKNOWN;
            // Use const reference to avoid copying the operand vector each time
            const vector<string>* operands_ptr = nullptr;
            string instr_str = "(fetch error)";

            if (idx >= parsed_instructions.size()) {
                cout << "\nPC " << hex << pc << dec << " index error (idx=" << idx << ", size=" << parsed_instructions.size() << ")" << endl;
                break;
            }
            const auto& instruction_pair = parsed_instructions[idx];
            opcode_id = instruction_pair.first;
            operands_ptr = &instruction_pair.second; // Point to the operands vector


            if (idx < instruction_strings.size()) {
                instr_str = instruction_strings[idx];
            }

            // --- Execute ---
            IC[opcode_id]++;
            count++;
            uint32_t orig_pc = pc;
            bool branch = false;

            // Ensure operands_ptr is valid before dereferencing
            if (!operands_ptr) {
                cerr << "Error: Null operands pointer for instruction at PC 0x" << hex << pc << dec << endl;
                exit(1);
            }
            const vector<string>& current_operands = *operands_ptr; // Dereference

            try {
                // Dispatch using switch statement
                switch(opcode_id) {
                    case OP_ADD: branch = sim_add(current_operands); break;
                    case OP_SUB: branch = sim_sub(current_operands); break;
                    case OP_ADDI: branch = sim_addi(current_operands); break;
                    case OP_AND: branch = sim_and(current_operands); break;
                    case OP_OR: branch = sim_or(current_operands); break;
                    case OP_NOR: branch = sim_nor(current_operands); break;
                    case OP_ORI: branch = sim_ori(current_operands); break;
                    case OP_ANDI: branch = sim_andi(current_operands); break;
                    case OP_XORI: branch = sim_xori(current_operands); break;
                    case OP_LW: branch = sim_lw(current_operands); break;
                    case OP_SW: branch = sim_sw(current_operands); break;
                    case OP_LB: branch = sim_lb(current_operands); break;
                    case OP_SB: branch = sim_sb(current_operands); break;
                    case OP_LA: branch = sim_la(current_operands); break;
                    case OP_LI: branch = sim_li(current_operands); break;
                    case OP_BEQ: branch = sim_beq(current_operands); break;
                    case OP_BNE: branch = sim_bne(current_operands); break;
                    case OP_J: branch = sim_j(current_operands); break;
                    case OP_JAL: branch = sim_jal(current_operands); break;
                    case OP_JR: branch = sim_jr(current_operands); break;
                    case OP_SLT: branch = sim_slt(current_operands); break;
                    case OP_SGT: branch = sim_sgt(current_operands); break;
                    case OP_SLL: branch = sim_sll(current_operands); break;
                    case OP_SRL: branch = sim_srl(current_operands); break;
                    case OP_SLLV: branch = sim_sllv(current_operands); break;
                    case OP_SRLV: branch = sim_srlv(current_operands); break;
                    case OP_MOVE: branch = sim_move(current_operands); break;
                    case OP_MULT: branch = sim_mult(current_operands); break;
                    case OP_MFLO: branch = sim_mflo(current_operands); break;
                    case OP_MFHI: branch = sim_mfhi(current_operands); break;
                    case OP_MTC1: branch = sim_mtc1(current_operands); break;
                    case OP_MFC1: branch = sim_mfc1(current_operands); break;
                    case OP_ADD_S: branch = sim_add_s(current_operands); break;
                    case OP_SUB_S: branch = sim_sub_s(current_operands); break;
                    case OP_MUL_S: branch = sim_mul_s(current_operands); break;
                    case OP_DIV_S: branch = sim_div_s(current_operands); break;
                    case OP_L_S: branch = sim_l_s(current_operands); break;
                    case OP_S_S: branch = sim_s_s(current_operands); break;
                    case OP_CVT_S_W: branch = sim_cvt_s_w(current_operands); break;
                    case OP_CVT_W_S: branch = sim_cvt_w_s(current_operands); break;
                    case OP_MOV_S: branch = sim_mov_s(current_operands); break;
                    case OP_SYSCALL: {
                        #if __cplusplus >= 201703L
                        optional<string> result = sim_syscall(current_operands);
                        if (result.has_value()) {
                            if (result.value() == "exit") { cout << "Syscall exit." << endl; goto end_exec_loop; }
                            if (result.value() == "error") { cerr << "Syscall error." << endl; goto end_exec_loop; } // Consider exiting with error code?
                        }
                        #else
                        string result = sim_syscall(current_operands);
                        if (!result.empty()) {
                            if (result == "exit") { cout << "Syscall exit." << endl; goto end_exec_loop; }
                            if (result == "error") { cerr << "Syscall error." << endl; goto end_exec_loop; }
                        }
                        #endif
                        branch = false;
                        break;
                    }
                    case OP_H: branch = sim_h(current_operands); break;
                    case OP_X: branch = sim_x(current_operands); break;
                    case OP_CNOT: branch = sim_cnot(current_operands); break;
                    case OP_MEASURE: branch = sim_measure(current_operands); break;
                    case OP_RESET: branch = sim_reset(current_operands); break;

                    case OP_UNKNOWN:
                        throw runtime_error("Encountered unknown opcode ID during execution: " + to_string(opcode_id));
                    default:
                        throw runtime_error("Unhandled opcode ID in switch: " + to_string(opcode_id));
                }

                // Update PC if instruction didn't branch/jump
                if (!branch) {
                    pc += 4;
                }
            } catch (const exception& e) {
                cerr << "\n--- Runtime Error ---\nPC=0x" << hex << orig_pc << dec
                    << " (" << idx << "): '" << instr_str << "'" << endl;
                cerr << typeid(e).name() << ": " << e.what() << "\n--------------------\n";
                sim_print_registers(); cerr << "--------------------\n";
                sim_print_quantum_state(); cerr << "--------------------\n";
                exit(1);
            }
        }

    end_exec_loop:; // Label for goto break

        if (summary) {
            cout << "\n--- Exec Summary ---" << endl;
            sim_print_registers();
            cout << "--------------------" << endl;
            sim_print_quantum_state();
            cout << "--------------------" << endl;
            cout << "Instruction Count:" << endl;
            uint64_t total_instructions = 0;
            for(const auto& pair : IC) total_instructions += pair.second;

            map<int, string> id_to_opcode_str;
            for(const auto& pair : OPCODE_STR_TO_ID) id_to_opcode_str[pair.second] = pair.first;

            int items_printed = 0;
            for(const auto& pair : IC) { // Iterate ordered map
                string op_name = id_to_opcode_str.count(pair.first) ? id_to_opcode_str[pair.first] : "ID(" + to_string(pair.first) + ")";
                cout << left << setw(10) << op_name + ":" << left << setw(7) << pair.second << " ";
                items_printed++;
                if (items_printed % 5 == 0) cout << endl;
            }
            if (items_printed % 5 != 0) cout << endl;

            cout << "Total: " << total_instructions << endl;
            const double Tc = 10.5e-9;
            double est_t = static_cast<double>(total_instructions) * Tc;
            cout << "Est Time: " << fixed << setprecision(6) << est_t << " s" << endl;
        }
    }
// === END SECTION 9 ===

// --- Unit Test for Section 9 ---
    void test_sim_run() {
        cout << "Testing sim_run (Integration)..." << endl;
        const string test_file_name = "temp_run_test.s";
        // Simple program that adds two numbers and exits
        const string asm_content = R"(
    .text
    main:
        li $t0, 100
        li $t1, 55
        add $t2, $t0, $t1  # t2 should become 155
        # Exit syscall
        li $v0, 10
        syscall
    )";

        if (!write_temp_file(test_file_name, asm_content)) {
            cerr << "Failed to write temporary file for run test." << endl; assert(false); return;
        }

        // Run the simulation
        sim_load_program(test_file_name);
        sim_run(false); // Run without summary for this test

        // Check final state (basic)
        assert(_get_register_value("$t2") == 155); // Check result of add
        // PC check is difficult as it depends on exact exit point, but should be >= end

        // Clean up
        remove(test_file_name.c_str());

        // Test instruction limit (optional)
        // Create a program with an infinite loop and run with limit

        cout << "sim_run Test Passed (basic)." << endl;
    }
// --- End Unit Test ---

// === SECTION 10: Printing Functions ===

    void sim_print_registers() {
        cout << "Integer Registers:" << endl;
        vector<pair<string, int32_t>> gprs = {
            {"$zero", 0}, {"$at", reg_at}, {"$v0", reg_v0}, {"$v1", reg_v1}
        };
        for(int i=0; i<4; ++i) gprs.push_back({"$a" + to_string(i), reg_a[i]});
        for(int i=0; i<10; ++i) gprs.push_back({"$t" + to_string(i), reg_t[i]});
        for(int i=0; i<10; ++i) gprs.push_back({"$s" + to_string(i), reg_s[i]});
        gprs.push_back({"$k0", reg_k0}); gprs.push_back({"$k1", reg_k1});
        gprs.push_back({"$gp", static_cast<int32_t>(reg_gp)}); // Cast for printing consistency
        gprs.push_back({"$sp", static_cast<int32_t>(reg_sp)});
        gprs.push_back({"$fp", reg_fp}); gprs.push_back({"$ra", reg_ra});
        gprs.push_back({"$lo", reg_lo}); gprs.push_back({"$hi", reg_hi});

        cout << hex << setfill('0');
        for(const auto& p : gprs) {
            uint32_t val_u = static_cast<uint32_t>(p.second);
            cout << " " << left << setw(5) << p.first + ":"
                << right << setw(12) << dec << p.second
                << " (0x" << hex << setw(8) << val_u << ")" << endl;
        }

        cout << " " << left << setw(5) << "PC" << "    :"
            << right << setw(12) << dec << static_cast<int32_t>(pc) // PC is address, print unsigned hex mainly
            << " (0x" << hex << setw(8) << pc << ")" << endl;
        cout << dec << setfill(' '); // Reset format

        cout << "\nFloating Point Registers:" << endl;
        cout << scientific << setprecision(8);
        for(int i=0; i<32; ++i) {
            string reg_name = "$f" + to_string(i);
            double fv = _get_float_from_fpr(reg_name);
            cout << " " << left << setw(5) << reg_name + ":"
                << right << setw(16) << fv << endl;
        }
        cout << defaultfloat << setprecision(6); // Reset format
    }

    // Helper definitions needed here if not defined earlier
    void print_segment_words_cpp(const vector<uint8_t>& seg_list, uint32_t base_addr, const string& name, int max_count) {
        cout << "\n--- " << name << " Segment (Base: 0x" << hex << base_addr << dec << ") ---" << endl;
        size_t seg_len = seg_list.size();
        int printed_count = 0;
        uint32_t addr = base_addr;
        size_t byte_idx = 0;

        cout << hex << setfill('0'); // Set hex format for addresses

        while (byte_idx < seg_len && printed_count < max_count) {
            if (addr % 4 == 0) {
                try {
                    uint8_t b3 = (byte_idx < seg_len) ? seg_list.at(byte_idx) : 0;
                    uint8_t b2 = (byte_idx + 1 < seg_len) ? seg_list.at(byte_idx + 1) : 0;
                    uint8_t b1 = (byte_idx + 2 < seg_len) ? seg_list.at(byte_idx + 2) : 0;
                    uint8_t b0 = (byte_idx + 3 < seg_len) ? seg_list.at(byte_idx + 3) : 0;

                    uint32_t wv_u = (static_cast<uint32_t>(b3) << 24) | (static_cast<uint32_t>(b2) << 16) |
                                    (static_cast<uint32_t>(b1) << 8) | static_cast<uint32_t>(b0);
                    int32_t wvs = static_cast<int32_t>(wv_u);

                    cout << " 0x" << setw(8) << addr << ": " << dec // Print address hex, switch to dec
                        << left << setw(12) << wvs
                        << " (Bytes: [" << static_cast<int>(b3) << "," << static_cast<int>(b2) << ","
                        << static_cast<int>(b1) << "," << static_cast<int>(b0) << "])" << endl;

                    printed_count++;
                } catch (const out_of_range& oor) { /* Should not happen */ }
            }
            addr += 4;
            byte_idx += 4;
        }
        if (seg_len == 0) cout << " (empty)" << endl;
        if (printed_count >= max_count && byte_idx < seg_len) {
            cout << " (Limit reached for this segment)..." << endl;
        }
        cout << dec << setfill(' '); // Reset format
    }

    void print_dict_entries_cpp(const unordered_map<uint32_t, uint8_t>& mem_dict, const string& name, int max_count) {
        cout << "\n--- " << name << " Segment (Dictionary) ---" << endl;
        size_t dict_len = mem_dict.size();
        int printed_count = 0;

        vector<uint32_t> sorted_keys;
        sorted_keys.reserve(mem_dict.size());
        for(const auto& pair : mem_dict) sorted_keys.push_back(pair.first);
        sort(sorted_keys.begin(), sorted_keys.end());

        map<uint32_t, array<uint8_t, 4>> words;
        map<uint32_t, bool> byte_used;

        cout << hex << setfill('0'); // Set hex format

        for (uint32_t addr : sorted_keys) {
            if (byte_used[addr]) continue;
            if (addr % 4 == 0) {
                array<uint8_t, 4> current_word_bytes = {0, 0, 0, 0}; // B3, B2, B1, B0
                for (int i = 0; i < 4; ++i) {
                    uint32_t byte_addr = addr + i;
                    auto it = mem_dict.find(byte_addr);
                    if (it != mem_dict.end()) current_word_bytes[3 - i] = it->second;
                }
                words[addr] = current_word_bytes;
                for (int i = 0; i < 4; ++i) byte_used[addr + i] = true;
            }
        }

        for (const auto& word_pair : words) {
            if (printed_count >= max_count) break;
            uint32_t word_addr = word_pair.first;
            const auto& bytes = word_pair.second;

            uint32_t wv_u = (static_cast<uint32_t>(bytes[0]) << 24) | (static_cast<uint32_t>(bytes[1]) << 16) |
                            (static_cast<uint32_t>(bytes[2]) << 8) | static_cast<uint32_t>(bytes[3]);
            int32_t wvs = static_cast<int32_t>(wv_u);

            cout << " 0x" << setw(8) << word_addr << ": " << dec // Print addr hex, switch to dec
                << left << setw(12) << wvs
                << " (Bytes: [" << static_cast<int>(bytes[0]) << "," << static_cast<int>(bytes[1]) << ","
                << static_cast<int>(bytes[2]) << "," << static_cast<int>(bytes[3]) << "])" << endl;
            printed_count++;
        }

        // Print remaining individual bytes (optional)
        // ...

        if (dict_len == 0) cout << " (empty)" << endl;
        if (printed_count >= max_count && static_cast<size_t>(printed_count * 4) < dict_len) { // Approx check
            cout << " (Limit reached for this segment)..." << endl;
        }
        cout << dec << setfill(' '); // Reset format
    }

    void sim_print_memory(int limit = 32) {
        cout << "\nMemory Segments (approx first " << limit << " words/entries per segment):";

        cout << "\n--- Text Segment (Base: 0x" << hex << CODE_BASE_ADDRESS << dec << ") ---" << endl;
        cout << " (Instructions fetched from parsed list, not byte memory in this model)" << endl;

        print_segment_words_cpp(mem_data, DATA_BASE_ADDRESS, "Static Data", limit);
        print_dict_entries_cpp(mem_high, "Heap/Meta", limit);

        // --- Stack Printing ---
        cout << "\n--- Stack Segment (Top: 0x" << hex << STACK_BASE_ADDRESS << dec << ") ---" << endl;
        size_t stack_len = mem_stack.size();
        int printed_count = 0;
        size_t stack_idx = 0; // Index from start of vector (highest address area)

        cout << hex << setfill('0'); // Set hex format

        while (stack_idx < stack_len && printed_count < limit) {
            // Word boundaries in the list are 0, 4, 8...
            if (stack_idx % 4 == 0) {
                // Calculate address of the word corresponding to this block
                uint32_t word_addr = STACK_BASE_ADDRESS - (stack_idx + 3) -1; // Address of lowest byte in the word
                                                                        // Index 0 -> Addr BASE-1..BASE-4
                                                                        // Index 4 -> Addr BASE-5..BASE-8
                                                                        // Word starting at Index 'idx' has lowest byte address BASE - idx - 4 ? No, BASE-idx-1?
                                                                        // Let's recalculate:
                                                                        // Index 0 is addr BASE-1
                                                                        // Index 1 is addr BASE-2
                                                                        // Index 2 is addr BASE-3
                                                                        // Index 3 is addr BASE-4  <- Word Addr
                                                                        // Index 4 is addr BASE-5
                                                                        // Index 7 is addr BASE-8  <- Word Addr
                word_addr = STACK_BASE_ADDRESS - (stack_idx + 4); // Lowest byte address for word starting at stack_idx

                if (word_addr % 4 == 0) { // Ensure word address is aligned (should be if logic correct)
                    try {
                        size_t idx_b3 = stack_idx + 0; // Highest addr byte
                        size_t idx_b2 = stack_idx + 1;
                        size_t idx_b1 = stack_idx + 2;
                        size_t idx_b0 = stack_idx + 3; // Lowest addr byte

                        uint8_t b3 = (idx_b3 < stack_len) ? mem_stack.at(idx_b3) : 0;
                        uint8_t b2 = (idx_b2 < stack_len) ? mem_stack.at(idx_b2) : 0;
                        uint8_t b1 = (idx_b1 < stack_len) ? mem_stack.at(idx_b1) : 0;
                        uint8_t b0 = (idx_b0 < stack_len) ? mem_stack.at(idx_b0) : 0;

                        uint32_t wv_u = (static_cast<uint32_t>(b3) << 24) | (static_cast<uint32_t>(b2) << 16) |
                                        (static_cast<uint32_t>(b1) << 8)  | static_cast<uint32_t>(b0);
                        int32_t wvs = static_cast<int32_t>(wv_u);

                        cout << " 0x" << setw(8) << word_addr << ": " << dec
                            << left << setw(12) << wvs
                            << " (Bytes: [" << static_cast<int>(b3) << "," << static_cast<int>(b2) << ","
                            << static_cast<int>(b1) << "," << static_cast<int>(b0) << "])" << endl;
                        printed_count++;

                    } catch (const out_of_range& oor) { /* Ignore */ }
                }
            }
            stack_idx += 4; // Move down list (up stack) by one word
        }
        if (stack_len == 0) cout << " (empty)" << endl;
        if (printed_count >= limit && stack_idx < stack_len) {
            cout << " (Limit reached for this segment)..." << endl;
        }
        cout << dec << setfill(' '); // Reset format
    }

    void sim_print_data_segment() {
        cout << ".data segment Labels:" << endl;
        if (data_segment.empty()) { cout << " (empty)" << endl; return; }
        map<string, uint32_t> sorted_labels(data_segment.begin(), data_segment.end());
        cout << hex;
        for (const auto& pair : sorted_labels) cout << " " << pair.first << ": @ 0x" << pair.second << endl;
        cout << dec;
    }

    void sim_print_quantum_state() {
        cout << "*** Quantum State ***" << endl;
        cout << "* Qubits: " << NUM_QUBITS << " Dim: " << STATE_SIZE << endl;

        double n_sq = 0.0; for (const auto& a : quantum_state) n_sq += norm(a);
        double n_f = sqrt(n_sq);
        if (abs(n_f - 1.0) > _FLOAT_ZERO_TOLERANCE) cout << "* (Warn: Norm " << fixed << setprecision(6) << n_f << ")" << endl;

        vector<string> lines_to_print; double total_prob_printed = 0.0; int amps_below_threshold = 0;
        const double prob_threshold = _FLOAT_ZERO_TOLERANCE * _FLOAT_ZERO_TOLERANCE;
        cout << fixed << setprecision(5);

        for (size_t i = 0; i < STATE_SIZE; ++i) {
            complex<double> a = quantum_state[i]; double p = norm(a);
            if (p > prob_threshold) {
                string binary_string;
                for (int k = 0; k < NUM_QUBITS; ++k) binary_string += ((i >> (NUM_QUBITS - 1 - k)) & 1) ? '1' : '0';
                stringstream ss; ss << " |" << binary_string << "> : (" << a.real() << (a.imag() >= 0 ? "+" : "") << a.imag() << "j) (P: " << p << ")";
                lines_to_print.push_back(ss.str()); total_prob_printed += p;
            } else amps_below_threshold++;
        }

        if (lines_to_print.empty()) cout << " (All amps below threshold)" << endl;
        else for (const auto& line : lines_to_print) cout << line << endl;
        if (amps_below_threshold > 0) {
            double prob_omit = max(0.0, 1.0 - total_prob_printed);
            cout << " (" << amps_below_threshold << " amps below threshold, ~P omit: " << prob_omit << ")" << endl;
        }
        cout << defaultfloat << setprecision(6);
    }
// === END SECTION 10 ===

// --- Unit Test for Section 10 ---
    void test_printing_functions() {
        cout << "Testing Printing Functions..." << endl;
        sim_initialize();

        // Set some state to print
        _set_register_value("$sp", 0x5FFF0010);
        _set_register_value("$a0", 42);
        _set_register_value("$f0", float_to_int_bits(1.23));
        _set_mem_word(DATA_BASE_ADDRESS, 111);
        _set_mem_byte(STACK_BASE_ADDRESS - 1, 222); // Offset 0
        mem_high[0x70000000] = 55;
        labels["my_label"] = 0x400100;
        data_segment["my_data"] = DATA_BASE_ADDRESS;

        cout << "\n--- Output from sim_print_registers ---" << endl;
        sim_print_registers();
        cout << "\n--- Output from sim_print_memory ---" << endl;
        sim_print_memory(5); // Print limited output
        cout << "\n--- Output from sim_print_data_segment ---" << endl;
        sim_print_data_segment();
        cout << "\n--- Output from sim_print_quantum_state ---" << endl;
        sim_print_quantum_state(); // Prints |00000> state
        cout << "\n--- End Printing Output ---" << endl;

        // Basic test: Just ensures functions run without crashing
        cout << "Printing Functions Test Passed (visual check required)." << endl;
    }
// --- End Unit Test ---

// === TEST RUNNER Section ===
    #ifndef RUN_SIMULATION // Use preprocessor guard if separating test code

    // Forward Declarations for all test functions
    void test_globals_and_constants();
    void test_sim_initialize();
    void test_memory_access();
    void test_register_access();
    void test_utilities();
    void test_load_parse();
    void test_quantum_helpers();
    void test_instruction_handlers();
    void test_sim_run();
    void test_printing_functions();
    void test_main_execution(const std::string& test_asm_content, bool expect_success);


    // Test Runner Function Definition
    void run_all_tests() {
        cout << "===== Running All Unit Tests =====" << endl;
        try {
            test_globals_and_constants();
            test_sim_initialize();
            test_memory_access();
            test_register_access();
            test_utilities();
            test_load_parse(); // Depends on file I/O
            test_quantum_helpers();
            test_instruction_handlers();
            test_sim_run(); // Integration check
            test_printing_functions(); // Visual check mainly
            // Test main execution sequence (basic load check)
            test_main_execution(R"(.text\nmain: li $v0,10\nsyscall\n)", true);
        } catch (const exception& e) {
            cerr << "\n!!! TEST FAILED WITH EXCEPTION: " << e.what() << " !!!" << endl;
            exit(1); // Exit if any test throws uncaught exception
        } catch (...) {
            cerr << "\n!!! TEST FAILED WITH UNKNOWN EXCEPTION !!!" << endl;
            exit(1);
        }
        cout << "\n===== All Unit Tests Passed =====" << endl;
    }

    void test_main_execution(const std::string& test_asm_content, bool expect_success) {
        cout << "Testing main execution (" << (expect_success ? "expect success" : "expect failure") << ")..." << flush;
        const std::string test_file = "temp_main_test.s";
        if (!write_temp_file(test_file, test_asm_content)) { cerr << " Failed main test file write." << endl; assert(false); return; }
        bool success = true; try { sim_load_program(test_file); assert(!parsed_instructions.empty()); } catch (const exception& e) { success = false; cerr << " Exception in main test load: " << e.what() << endl; }
        assert(success == expect_success); remove(test_file.c_str());
        cout << " [PASS]" << endl;
    }

    #endif // RUN_SIMULATION
// === END TEST RUNNER Section ===



// === SECTION 11: main Function ===



    // // Main function for running the simulation
    int main(int argc, char* argv[]) {
        // --- Sanity Check Constants ---
        if (STACK_SEGMENT_BOTTOM <= DATA_BASE_ADDRESS) { // Check for non-overlap
            cerr << "CRITICAL ERROR: Calculated STACK_SEGMENT_BOTTOM 0x" << hex << STACK_SEGMENT_BOTTOM
                << " overlaps/touches DATA_BASE_ADDRESS 0x" << DATA_BASE_ADDRESS << dec << endl;
            return 1;
        }
        if (STATIC_DATA_END != STACK_SEGMENT_BOTTOM) {
            cerr << "CRITICAL ERROR: STATIC_DATA_END mismatch with STACK_SEGMENT_BOTTOM" << endl;
            return 1;
        }
        if (HEAP_META_BASE_ADDRESS != STACK_BASE_ADDRESS) {
                cerr << "CRITICAL ERROR: HEAP_META_BASE mismatch with STACK_BASE" << endl;
            return 1;
        }
        if (HEAP_META_END_ADDRESS <= HEAP_META_BASE_ADDRESS) {
            cerr << "CRITICAL ERROR: Invalid HEAP_META range" << endl;
            return 1;
        }


        if (argc < 2) {
            cerr << "Usage: " << (argc > 0 ? argv[0] : "mips_simulator") << " <assembly_file.s>" << endl;
            return 1;
        }
        string file_path = argv[1];

        ifstream check_file(file_path);
        if (!check_file) {
            cerr << "Error: Input file '" << file_path << "' not found or not accessible." << endl;
            return 1;
        }
        check_file.close();


        try {
            sim_load_program(file_path);
            sim_run(true); // Run with summary
        } catch (const exception& e) {
            cerr << "\n--- Unexpected Error Encountered ---" << endl;
            cerr << "Error Type: " << typeid(e).name() << endl;
            cerr << "Error Message: " << e.what() << endl;
            return 1;
        } catch (...) {
            cerr << "\n--- Unknown Non-Standard Exception Encountered ---" << endl;
            return 1;
        }

        cout << "\nSimulation finished successfully." << endl;
        return 0; // Success
    }


    // // --- Optional: Main function for running tests ---
    // int main() {
    //     run_all_tests();
    //     return 0;
    // }

// === END SECTION 11 ===
