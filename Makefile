WORKSPACE = Example/RSDayFlowExample.xcworkspace
SCHEME = RSDayFlowExample
CONFIGURATION = Release
DEVICE_HOST = platform='iOS Simulator',OS='11.2',name='iPhone X'

.PHONY: all build ci clean lint

all: ci

build:
	set -o pipefail && xcodebuild -workspace $(WORKSPACE) -scheme $(SCHEME) -configuration '$(CONFIGURATION)' -sdk iphonesimulator -destination $(DEVICE_HOST) build | bundle exec xcpretty -c

clean:
	xcodebuild -workspace $(WORKSPACE) -scheme $(SCHEME) -configuration '$(CONFIGURATION)' clean

lint:
	bundle exec fui --path Example/RSDayFlowExample find

ci: CONFIGURATION = Debug
ci: build

bundler:
	gem install bundler
	bundle install
