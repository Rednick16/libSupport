# Jailed-Support
support for jailed tweaks on non-jailbroken devices to bypass sideload detection.
and other checks developers have put in place.

# Usage
- Files need to be added to `Frameworks` folder
```cpp
    struct support_bypass bypass = {
        NULL, /* custom uniuque id to spoof app no use for now */
        "com.rednick16.jailed.example", /* your app bundle id most basic detection but effective */
        {
			/* add any files u wish to bypass here */
            "embedded",
            "mobileprovision",
            "jailed_example",
            "libsupport"
        },
        {
			/* add any symbols u wish to bypass here */
			"example_symbol",
			"MSHookFunction",
			"MSHookMessage"
		}
    };
    
    initilize(bypass);
```

# Where is libsupport source?
Well to prevent libsupport from being detected faster iv decided to keep source closed for now

# Please read
this is measly for educational purposes only please don't go moddifying other devlopers applications without permision.

# Check List
- add a custom info.plist file to link to
- add the original .app to link to, instead of checking the moddified one
- you tell, will see

# Credits
- Rednick16 (CREATOR)
- Busmanl30 (IDEA)