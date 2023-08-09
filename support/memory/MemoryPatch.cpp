#include "MemoryPatch.h"
#include "support.h"

namespace Support
{
    MemoryPatch::MemoryPatch()
    {
        _address = NULL;
        _size = 0;
        _orig_data.clear();
        _patch_data.clear();
        _adjustCallback = NULL;
        _revertCallback = NULL;
    }

    MemoryPatch::~MemoryPatch()
    {
        _orig_data.clear();
        _patch_data.clear();
    }

    MemoryPatch::MemoryPatch(void* address, const uint8_t* data, size_t size) : MemoryPatch()
    {
        if(!address || !data || size < 1 ) 
            return;

        _address = address;
        _size = size;

        _orig_data.resize(size);
        _patch_data.resize(size);

        std::memcpy(&_patch_data[0], data, size);
        std::memcpy(&_orig_data[0], address, size);
    }

    bool MemoryPatch::isValid() const {
        return (_address && _size > 0 && _orig_data.size() == _size && _patch_data.size() == _size);
    }

    size_t MemoryPatch::size() const {
        return _size;
    }

    void* MemoryPatch::address() const {
        return _address;
    }

    bool MemoryPatch::adjust()
    {
        if(!isValid()) 
            return false;

        bool success = SupportCodePatchEx(_address, &_patch_data[0], _size) == SUPPORT_SUCCESS;
        if(success) {
            if (_adjustCallback) {
                _adjustCallback(*this);
            }
        }

        return success;
    }

    bool MemoryPatch::revert()
    {
        if(!isValid()) 
            return false;

        bool success = SupportCodePatchEx(_address, &_orig_data[0], _size) == SUPPORT_SUCCESS;
        if(success) {
            if (_revertCallback) {
                _revertCallback(*this);
            }
        }

        return success;
    }

    void MemoryPatch::setAdjustCallback(std::function<void(MemoryPatch&)> callback) {
        _adjustCallback = callback;
    }

    void MemoryPatch::setRevertCallback(std::function<void(MemoryPatch&)> callback) {
        _revertCallback = callback;
    }

    std::string MemoryPatch::getOrigBytes() const {
        return std::string(reinterpret_cast<const char*>(_orig_data.data()), _orig_data.size());
    }

    std::string MemoryPatch::getPatchBytes() const {
        return std::string(reinterpret_cast<const char*>(_patch_data.data()), _patch_data.size());
    }

    bool MemoryPatch::operator==(const MemoryPatch& rhs) const {
    return address() == rhs.address() &&
           size() == rhs.size() &&
           getOrigBytes() == rhs.getOrigBytes() &&
           getPatchBytes() == rhs.getPatchBytes();
    }

    bool MemoryPatch::operator!=(const MemoryPatch& rhs) const {
        return !(*this == rhs);
    }
}