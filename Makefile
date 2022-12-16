# h/t to @jimhester and @yihui for this parse block:
# https://github.com/yihui/knitr/blob/dc5ead7bcfc0ebd2789fe99c527c7d91afb3de4a/Makefile#L1-L4
# Note the portability change as suggested in the manual:
# https://cran.r-project.org/doc/manuals/r-release/R-exts.html#Writing-portable-packages
export PKGNAME=`sed -n "s/Package: *\([^ ]*\)/\1/p" DESCRIPTION`
export PKGVERS=`sed -n "s/Version: *\([^ ]*\)/\1/p" DESCRIPTION`
export DATETIME=`date +%Y-%m-%d\ %H:%M:%S`
export DATETIMEUTC=`date -u +%Y-%m-%d\ %H:%M:%S`
export DATE=`date +%Y.%-m.%-d`

#export PWD=$(abspath $(lastword $(MAKEFILE_LIST)))

all: build

.ONESHELL:
fix_description_version:
	sed -i "s/^Version: .*/Version: $(DATE)/" DESCRIPTION
	sed -i '/Date\/Publication:/d' DESCRIPTION # delete if exists
	echo "Date/Publication: $(DATETIMEUTC) UTC" >> DESCRIPTION #append to bottom
	chmod -R 777 ..

.ONESHELL:
build_data:
	docker run --rm --privileged \
		-v $(shell pwd):/rpkg \
		docker.io/fhix/rfhiverse:latest /bin/bash -c \
		'Rscript -e "devtools::load_all(\"/rpkg/\"); gen_data_all(\"/rpkg/data\")"'
	chmod -R 777 ..

.ONESHELL:
build_package:
	rm -rf ../built
	mkdir ../built
	docker run --rm --privileged \
		-v "/Users/andrea/docker-volumes/chi-hub/agent-pipelines/$(PKGNAME)/rpkg:/rpkg" \
		-v "/Users/andrea/docker-volumes/chi-hub/agent-pipelines/$(PKGNAME)/built:/built" \
		localhost/sc8-su-csverse:latest /bin/bash -c \
		' \
		cd /; \
		R CMD build /rpkg; \
		cp *.tar.gz /built/; \
		'
	chmod -R 777 ..

.ONESHELL:
check_package:
	docker run --rm --privileged \
		-v "/Users/andrea/docker-volumes/chi-hub/agent-pipelines/$(PKGNAME)/rpkg:/rpkg" \
		-v "/Users/andrea/docker-volumes/chi-hub/agent-pipelines/$(PKGNAME)/built:/built" \
		localhost/sc8-su-csverse:latest /bin/bash -c \
		' \
		R CMD check --no-manual /built/*.tar.gz; \
		mv *.Rcheck /built/; \
		'

	chmod -R 777 ..

	if grep -Fq "WARNING" ../built/*.Rcheck/00check.log
	then
		# code if found
		exit 1
	else
		# code if not found
		echo "NO WARNINGs"
	fi

	if grep -Fq "ERROR" ../built/*.Rcheck/00check.log
	then
		# code if found
		exit 1
	else
		# code if not found
		echo "NO ERRORs"
	fi

.ONESHELL:
drat:
	# spuls
	docker run --rm --privileged \
		-v "/Users/andrea/docker-volumes/chi-hub/agent-pipelines/$(PKGNAME)/rpkg:/rpkg" \
		-v "/Users/andrea/docker-volumes/chi-hub/agent-pipelines/$(PKGNAME)/built:/built" \
		-v "/Users/andrea/Documents/GitHub/drat:/drat" \
		localhost/sc8-su-csverse:latest /bin/bash -c 'Rscript -e "drat::insertPackage(fs::dir_ls(\"/built/\", regexp=\".tar.gz\$\"), repodir = \"/drat\", action=\"prune\")"'

	# sed -i "/## News/a - **$(PKGNAME) $(PKGVERS)** (linux) inserted at $(DATETIME)" ../drat/README.md
	# sed -i '1001,\\\$ d' ../drat_sp/README.md # only keep first 1000 lines of readme

	# git config --global user.email "sykdomspulsen@fhi.no"
	# git config --global user.name "sykdomspulsen"

	git -C /drat add -A
	git -C /drat commit -am "gocd $(PKGNAME) $(PKGVERS)" #Committing the changes
	git -C /drat push -f origin main #pushes to master branch


.ONESHELL:
pkgdown:
	docker run --rm --privileged \
		-v "/Users/andrea/docker-volumes/chi-hub/agent-pipelines/$(PKGNAME)/rpkg:/rpkg" \
		-v "/Users/andrea/docker-volumes/chi-hub/agent-pipelines/$(PKGNAME)/built:/built" \
		-v "/Users/andrea/Documents/GitHub/drat:/drat" \
		localhost/sc8-su-csverse:latest /bin/bash -c 'Rscript -e "devtools::install(\"/rpkg\", dependencies = TRUE, upgrade = FALSE); pkgdown::build_site(\"/rpkg\")"'

	if [ -d "docs" ]
	then
		git add docs
		git commit -am "Pkgdown built"
		git subtree split --prefix docs -b gh-pages
		git push -u -f origin gh-pages:gh-pages
		git branch -D gh-pages
		git reset --soft HEAD^
		git restore --staged .
		rm -rf docs
	else
		# code if not found
		echo "NO DOCS FOUND"
	fi
