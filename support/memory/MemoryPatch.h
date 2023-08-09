#include <vector>
#include <iostream>
#include <functional>

namespace Support
{
    class MemoryPatch {
    private:
        void* _address;
        size_t _size;

        std::vector<uint8_t> _orig_data;
        std::vector<uint8_t> _patch_data;

        std::function<void(MemoryPatch&)> _adjustCallback;
        std::function<void(MemoryPatch&)> _revertCallback;

    public:
        MemoryPatch();

        MemoryPatch(void* address, const uint8_t* data, size_t size);

        ~MemoryPatch();

        bool isValid() const;

        size_t size() const;

        void* address() const;

        bool adjust();

        bool revert();

        std::string getOrigBytes() const;
        std::string getPatchBytes() const;

        void setAdjustCallback(std::function<void(MemoryPatch&)> callback);
        void setRevertCallback(std::function<void(MemoryPatch&)> callback);

        // Operator overloads
        bool operator==(const MemoryPatch& rhs) const;
        bool operator!=(const MemoryPatch& rhs) const;
    };
}