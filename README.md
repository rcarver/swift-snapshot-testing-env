# SnapshotTestingEnvOverlay

A drop-in replacement for [swift-snapshot-testing](https://github.com/pointfreeco/swift-snapshot-testing) that allows the snapshots directory
to be configured via ENV variable.

This supports running on Xcode Cloud where tests don't have access to the file system,
with the exception of a `ci_scripts` directory. By symlinking your snapshots to 
`ci_scripts` and setting an ENV variable it's possible to run snapshot tests.

```bash
SNAPSHOTTESTING_PACKAGES_PATH=/Volumes/workspace/respository/ci_scripts/snapshots
```

Setting this ENV var means your snapshots are found in `ci_scripts/snapshots` instead of
the standard location relative to the test file. By *not* setting this variable in 
local development the normal snapshot location and workflow is untouched.

### Example Script

This script will symlink all `__Snapshots__` directories into `ci_scripts/snapshots`,
matching the path that's constructed by `SnapshotTestingEnv` when with the ENV 
variable above.

```bash
#!/bin/sh

set -e

snapshots=ci_scripts/snapshots
search_path_from_snapshots=../..

rm -rf $snapshots
mkdir $snapshots
cd $snapshots

find $search_path_from_snapshots -type d -name "__Snapshots__" | grep -v .build | while read dir; do
    parent=$(dirname "$dir")
    parent_name=${parent##*/}
    echo $parent_name $dir
    ln -s "$dir" "$parent_name"
done
```

## License 

MIT
