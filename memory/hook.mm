
#include <vector>
#include "memory.h"

/*******
using namespace std;

//ref chicken hook

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wtautological-bitwise-compare"

static size_t estimateFunctionSize(void *function) {
    size_t size = 0;
    uint8_t *address(reinterpret_cast<uint8_t *>(function));

    while (1) {
        // Check the opcode of the current instruction to determine its size
        uint8_t opcode = *address;
        size_t instruction_size = 4; // Default instruction size is 4 bytes

        if ((opcode & 0xFC) == 0x14) {
            // B or BL instruction
            instruction_size = 4; // 4-byte instruction
        } else if ((opcode & 0xFE) == 0x1A) {
            // B.cond instruction
            instruction_size = 4; // 4-byte instruction
        } else if ((opcode & 0xF8) == 0x54) {
            // B, BL, BR, or BLR instruction
            instruction_size = 4; // 4-byte instruction
        } else if ((opcode & 0xFC) == 0xD4) {
            // B, BL, CBNZ, or CBZ instruction
            instruction_size = 4; // 4-byte instruction
        } else if ((opcode & 0xFC) == 0x94) {
            // TBZ or TBNZ instruction
            instruction_size = 4; // 4-byte instruction
        } else if ((opcode & 0xF0) == 0x10) {
            // ADR instruction
            instruction_size = 4; // 4-byte instruction
        } else if ((opcode & 0xF8) == 0xF0) {
            // ADRP instruction
            instruction_size = 4; // 4-byte instruction
        }

        // Increment the size and address
        size += instruction_size;
        address += instruction_size;

        // Break the loop when encountering a return or branch instruction
        if (opcode == 0xC0 || opcode == 0xC1) {
            break;
        }
    }

    return size;
}

#pragma clang diagnostic pop

static vector<uint8_t> generateJump(void* src, void* dst) {
    vector<uint8_t> jmp{};
    jmp.resize(16); // jmp size

    jmp[0] = 0x49;
    jmp[1] = 0x00;
    jmp[2] = 0x00;
    jmp[3] = 0x58;
    jmp[4] = 0x20;
    jmp[5] = 0x01;
    jmp[6] = 0x1f;
    jmp[7] = 0xd6;

    uint64_t addr = (uint64_t)dst;
    _supportmem_copy(&jmp[8], &addr, sizeof(addr));
    return jmp;
}

int _supportmem_hookfunction_64(void* function, void* replacement, void** result) {
    auto jmp(generateJump(function, replacement));

    if(result != NULL) {

        size_t length = estimateFunctionSize(function);
        LS_LOG("_supportmem_hookfunction_64() estimated function size (%zu)", length);

        uint8_t *buffer(reinterpret_cast<uint8_t *>(__mmap(
            NULL, length, (LSM_PROT_READ|LSM_PROT_WRITE), (MAP_PRIVATE|MAP_ANONYMOUS), -1, 0
        )));

        if(buffer == NULL || buffer == MAP_FAILED) {
            LS_LOG("_supportmem_hookfunction_64() mmap failed! error (%d)", errno);
            *result = NULL;
            return 0;
        }

        if (false) fail: {
            munmap(buffer, length);
            *result = NULL;
            return 0;
        }
        
        _supportmem_copy(buffer, function, jmp.size());

        auto backjmp(generateJump(
            &buffer[jmp.size()], (void *)((uint8_t *)function + jmp.size()
        )));

        _supportmem_copy(&buffer[jmp.size()], &backjmp[0], backjmp.size());
        
        if(_supportmem_protect(buffer, backjmp.size(), (LSM_PROT_READ|LSM_PROT_EXEC)) == 0) {
            //LS_LOG("Support:Error:vm_protect() = %d", errno);
            goto fail;
        }

        *result = buffer;
    }
    
    return _supportmem_code_patch(function, &jmp[0], jmp.size());
}
*/

// I have expended all resources on this, time to use somthing else.
int _supportmem_hookfunction_64(void* function, void* replacement, void** result) 
{
}