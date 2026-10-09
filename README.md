# BodyGen Template Builder

**Drag. Drop. Done!**

BodyGen Template Builder is a small Windows batch tool for Fallout 4 that converts BodySlide XML presets into correctly formatted BodyGen `templates.ini` entries. Drop one or more BodySlide XML preset files onto the batch file to add or update your BodyGen templates.

## Features

- Converts one or multiple BodySlide XML presets by drag and drop.
- Creates `templates.ini` in the same folder as the batch file if it does not exist.
- Adds new presets to `templates.ini` and updates existing entries with matching names.
- Detects malformed XML and reports conversion failures.
- Displays conversion results in a console window.
- Uses Windows batch and the PowerShell included with Windows 10/11; no separate tools or compiled components are required.

## Requirements

- Windows 10 or Windows 11.
- BodySlide XML preset files to convert.
- A Fallout 4 BodyGen setup to use the generated templates in game.

## Installation and use

1. Download the tool from its [Nexus Mods page](https://www.nexusmods.com/fallout4/mods/109903).
2. Extract `BodyGenTemplateBuilder.bat` into the BodyGen folder containing your `templates.ini` and `morphs.ini`. If `templates.ini` does not yet exist, the tool will create it.
3. Drag and drop one or more BodySlide XML preset files onto `BodyGenTemplateBuilder.bat`.
4. Read the console output to check which presets succeeded or failed.
5. Check `templates.ini` in the same folder. New presets will be appended; existing entries with exactly matching names will be updated.

**Important:** Back up an existing `templates.ini` before first use, especially if you have customized it. The script writes the file again after processing its inputs.

## Enable your presets in BodyGen

Converting a BodySlide preset does not automatically assign it to any character. Open `morphs.ini` manually and add the custom preset name where appropriate, for example in the `All|Female|HumanRace=` or `All|Female|GhoulRace=` entries, or assign it to the Sole Survivor or your chosen NPCs.

Then clear and regenerate in-game BodyGen data so the new preset can take effect. For guidance, see the author's [Diverse CBBE BodyGen](https://www.nexusmods.com/fallout4/mods/108947) mod description and sticky post, including its Mod Configuration Menu procedure.

## Source code and build instructions

The complete tool is the single plain-text file [`BodyGenTemplateBuilder.bat`](BodyGenTemplateBuilder.bat), which includes its PowerShell conversion logic. **There is no compiled executable, and no build step is needed.** The repository publishes the unmodified v1.0 batch script distributed with the mod.

The batch file invokes Windows PowerShell to read its embedded script. Its `-ExecutionPolicy Bypass` argument applies to that PowerShell invocation; users should inspect scripts before running them.

## Licence

**Personal use only. All rights reserved.** You may download and run the unmodified tool, but you may not modify, redistribute, reupload, republish, incorporate it into another project, or claim it as your own without written permission. The tool’s generated BodyGen template data is not restricted by this licence. See [LICENSE.txt](LICENSE.txt) for the full terms.

## Nexus Mods

[BodyGen Template Builder for Fallout 4](https://www.nexusmods.com/fallout4/mods/109903)

Author: **broken9bot**
