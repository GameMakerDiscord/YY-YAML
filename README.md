# YY-YAML
YY-YAML (pronounced "why, why - YAML") is an application that lets you convert between Game Maker Studio 2's project format (YYP + `views` directory) and single-file nested YAML.
In a sense, it is a successor to my older [gmxorg](https://bitbucket.org/yal_cc/gmxorg/src/master/) tool.

This is primary intended for resolving merge conflicts when using version control software, which is generally considered to be one of the program's weakest points by professional users.

Maintained by [@YellowAfterlife](https://github.com/YellowAfterlife).  
Releases are hosted [on itch.io](https://yellowafterlife.itch.io/yy-yaml).

## How to use (in general)

- Drag a YYP file onto the program's executable to generate a YAML version of it in the same directory.
- Drag such a YAML file onto the program's executable to update the YYP and view files to match its contents.

Obviously you can also use the two via command-line.

## How to use (with git)

First, you want to make sure that your YAML is always updated together with YYP.

While you could just drag the YYP onto the executable manually, a nicer way of doing so is to instruct git to do so automatically.

For this you want to extract the `pre-commit` file and place it in your `.git/hooks` directory. Then place `YYYAML.exe` in the project directory.

Then, when you have a merge conflict, you can resolve the merge conflict (if any) in the YAML file, and run the tool to update your YYP+views to match. Since YY-YAML's format has each resource/directory only take a single line, it makes it far easier to figure out changes, and many things will not result in a merge conflict at all (because YAML doesn't use delimiters like JSON does).

For applying to a merge conflict that you already have:

1. Checkout a commit at the last merge point.
2. Generate a YAML file of the project.
3. Copy the file somewhere.
4. Checkout the current commit at the source branch, do the same.
5. Checkout the current commit at the destination branch, do the same.
6. Commit the file from step 3 into the source branch and pull that single commit into the destination branch.
7. Commit the file from step 4 into the source branch, but don't pull that yet.
8. Commit the file from step 5 into the destination branch.
9. Pull YAML changes from source branch into the destination branch, resolve merge conflicts, use the tool to generate a new YYP.

## Could YoYo Games do this themselves?

[Reportedly](https://forum.yoyogames.com/index.php?threads/come-meet-yoyo-at-gamescom.66372/#post-397569), some project format changes are scheduled for GMS2.3, which should be out in late 2019. The exact nature of changes is not known at this time.
