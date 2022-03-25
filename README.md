# AFToolkit
AFToolkit is a mono-repo library with all my helpers and support classes to build iOS, Android or Unity projects.

## iOS
- Installation:
	- Using in local projects:
	- Drag AFToolkit folder directly into project (to have editing capabilities)
	- MAY ONLY BE OPEN IN ONE PROJECT
	- Must be in git repo or XCode doesn't recognize it (March 2021)
- TODO:
	- Port SQLiteClient, AFArray from Obj C
- Swift Package Manager only allows git repos with one Package.swift in the root.
https://stackoverflow.com/questions/48666237/swift-package-manager-dependency-in-a-repository-subdirectory
- SPM requires the following be in the repository root:
	- Sources (with sub-folder naming aligning with each .target)
	- Tests (with sub-folder naming aligning with each .testTarget)

## Unity
- Installation:
	- Create a sym-link beneath the Unity project's Scripts folder, pointing to this library's "Unity/Scripts" folder.

## License
- TODO
