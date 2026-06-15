REPO_URL = https://gitlab.com/piveau/hub/piveau-hub-search.git/ 
REPO_DIR = piveau-hub-search
PATCH_FILE = $(CURDIR)/patch/semantic-search.patch

all: build

$(REPO_DIR): 
	git clone -c advice.detachedHead=false --branch 5.3.0 --depth 1 $(REPO_URL) $(REPO_DIR) 

$(REPO_DIR)/.patched: $(PATCH_FILE) | $(REPO_DIR)
	cd $(REPO_DIR) && git apply --whitespace=nowarn $(PATCH_FILE)
	touch $(REPO_DIR)/.patched

$(REPO_DIR)/target/search.jar:
	cd $(REPO_DIR) && mvn clean package -DskipTests
	cd $(REPO_DIR) && docker build -t piveau-hub-search-patched .

build: $(REPO_DIR)/.patched $(REPO_DIR)/target/search.jar

clean:
	docker image rm piveau-hub-search-patched 2>/dev/null || true
	rm -rf $(REPO_DIR)

.PHONY: all build clean
