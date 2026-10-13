PROJECT := Dozer.xcodeproj
DERIVED_DATA := build/DerivedData
APP := $(DERIVED_DATA)/Build/Products/Release/Dozer.app

project:
	@command -v xcodegen >/dev/null || (echo "Install XcodeGen first: brew install xcodegen" && exit 1)
	@xcodegen generate

build: project
	@xcodebuild \
		-project "$(PROJECT)" \
		-scheme Dozer \
		-configuration Release \
		-derivedDataPath "$(DERIVED_DATA)" \
		CODE_SIGNING_ALLOWED=NO \
		build
	@codesign --force --sign - "$(APP)"
	@echo "Built native Apple Silicon app: $(APP)"

open: project
	@xed "."

package: build
	@bash Scripts/PackageRelease.sh local "$(APP)"

release:
	@bash Scripts/PackageRelease.sh signed "$(APP)"

.PHONY: project build open package release
