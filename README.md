# YY-YAML
YY-YAML (pronounced "why, why - YAML") is an application that lets you convert between Game Maker Studio 2's project format (YYP + `views` directory) and single-file nested YAML.
In a sense, it is a successor to my older [gmxorg](https://bitbucket.org/yal_cc/gmxorg/src/master/) tool.

This is primary intended for resolving merge conflicts when using version control software, which is generally considered to be one of the program's weakest points by professional users.

Maintained by [@YellowAfterlife](https://github.com/YellowAfterlife).  
Releases are hosted [on itch.io](https://yellowafterlife.itch.io/yy-yaml).

## How does this work
As you might be vaguely aware, GameMaker Studio 2 stores your project structure in a YYP file (which contains resource paths and resource IDs) and series of "view" files (which correspond each each "folder" that you can see in the resource tree).

Both of these are in JSON format, which is good for serialization purposes, but much less so for merging changes in version control - even adding a file to the end of the same resource tree folder on both branches is automatically a merge conflict due to lack of trailing comma as per JSON specification. Additionally, resolving merges is a mess because you cannot quickly look up which resources are used based on ID.

On other hand, this tool produces YAML files that are structured exactly like resource tree - so, if you had a folder called "helpers" with scripts "trace" and "cycle", it might look like:
```yaml
- "helpers | GMScript | dabada57-7e5a-4efa-635c-2104241583f6 | be11fa39-5dad-186a-e5d7-3c222550332e": 
  - "?trace | GMScript | d66da385-176e-6cbc-1d57-a6b6eabab5b2 | 1ca59f3b-ca2b-4169-6b65-dec4afef73c6"
  - "?cycle | GMScript | 1cd3cdb6-14ee-ee8f-be85-dbf71c959574 | c95fb987-f975-933d-7e05-d53b8638bed0"
```
So each thing has its name/path, type, and both IDs all in the same line of YAML, which means that adding/removing resources/folders is a matter of changing a single line of code, and merge conflicts are less likely to occur to begin with.

Combine this with "interactive" merge modes in git clients like Sublime Merge, and working with version control is suddenly a breeze.

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
