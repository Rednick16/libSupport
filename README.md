# libSupport
_"Putting in place measures to restrict a person who is dedicated to achive his goals, you are just asking for a rebellion"_ - [Red16](https://github.com/Rednick16)


## The Story
It's 2021, I am playing video games, modding, sideloading having fun, but then suddenly somthing changed in `2022`, while sidloading some apps through out the year, I've started seeing pop-ups forcing me to download the game/app from the appstore this pissed me off ofc, so I decrypted one of the apps using `CrackerXI` (shout out to them) then loaded it up in `IDA Pro`, I am not new to software reverse-engineering, so I was quickly able to figure out wtf they were doing. These apps, they were simply doing basic bundleIdentifier checks and path checks, so I pulled out the method swizzling and started cracking away lol.
While chatting with one of my friends [busmanl30](https://github.com/busmanl30) on discord, he had been facing similar issues, seeing these anoying pop-ups he gived me the idea to create a tool, a tool everybody else can easily integrate into their tweaks. And thats how libSupport came to be.

## Usage
libSupport is already pretty easy to use and is self-explaintory, but some need a visaul representation.
include `support.h` into your main file or where-ever, add this code
```c
// Set constructor priority to 0, we wan't to make sure libSupport is the first thing initialized in our program.
LS_CTOR_(0)
{
    // Add any files you wish to restrict the target app from accessing.
    const char *files[] = {
        "embedded.mobileprovision", 
        "libSupport.dylib", 
        "CydiaSubstrate",
        "H5GG", 
        "iGameGod"
    };

    // Add any url schemes you wish to restrict the target app from opening/accessing.
    const char *urls[] = {

    };

    SupportEntryInfo entry_info = {
        .teamIdentifier = NULL,                         // The original team identifier of the target app (todo)
        .bundleIdentifier = NULL,                       // The original bundleIdentifier of the terget app (null-nochange)
        .hookFlags = SupportHookFlagEnableAll,          // Set of options to customize libSupport hooks
        .restrictedFiles = files,                       // The files the victim has no perm to access
        .restrictedFileCount = LS_ARRAYSIZE(files),     // The size of the restrictedFiles array
        .restrictedURLSchemes = urls,                   // The url schemes the victim has no perm to access
        .restrictedURLSchemeCount = LS_ARRAYSIZE(urls)  // The size of restrictedURLSchemes array
    };

    // Lets bully him
    SupportInitialize(&entry_info);
}
```

## What's next?
Well my to-do list is quite hefty already, so I am relying on the community to keep this software alive and functioning.
I plan to provide an xcode framework (LSAutoInjector.framework) which will have a configurable `SupportEntryInfo.json` to let signers or users configure this more easily.

## Credits
- [Rednick16](https://github.com/Rednick16)
- [Busmanl30](https://github.com/busmanl30)
- [jjolano (shadow)](https://github.com/jjolano/shadow)

## License
libSupport is licensed under the MIT License, see [support.h](support/support.h) for the full thing.