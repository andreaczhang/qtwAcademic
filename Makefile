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
	sudo chmod -R 777 ..

.ONESHELL:
build_data:
	sudo podman run --rm --privileged \
		-v $(shell pwd):/rpkg \
		docker.io/fhix/rfhiverse:latest /bin/bash -c \
		'Rscript -e "devtools::load_all(\"/rpkg/\"); gen_data_all(\"/rpkg/data\")"'
	sudo chmod -R 777 ..

.ONESHELL:
build_package:
	sudo rm -rf ../built
	mkdir ../built
	sudo podman run --rm --privileged \
		-v $(shell pwd):/rpkg \
		-v $(shell pwd)/../built:/built \
		docker.io/fhix/rfhiverse:latest /bin/bash -c \
		' \
		cd /; \
		R CMD build /rpkg; \
		cp *.tar.gz /built/; \
		'
	sudo chown -R go ../built
	sudo chmod -R 777 ..

.ONESHELL:
check_package:
	sudo podman run --rm --privileged \
		-v $(shell pwd):/rpkg \
		-v $(shell pwd)/../built:/built \
		docker.io/fhix/rfhiverse:latest /bin/bash -c \
		' \
		R CMD check --no-manual /built/*.tar.gz; \
		mv *.Rcheck /built/; \
		'

	sudo chmod -R 777 ..

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
	git -C .. clone git@github.com:sykdomspulsen-org/drat.git --branch gh-pages drat_sp
	sudo podman run --rm --privileged \
		-v $(shell pwd):/rpkg \
		-v $(shell pwd)/../built:/built \
		-v $(shell pwd)/../drat_sp:/drat \
		docker.io/fhix/rfhiverse:latest /bin/bash -c 'Rscript -e "drat::insertPackage(fs::dir_ls(\"/built/\", regexp=\".tar.gz\$\"), repodir = \"/drat\")"'

	# sed -i "/## News/a - **$(PKGNAME) $(PKGVERS)** (linux) inserted at $(DATETIME)" ../drat/README.md
	# sed -i '1001,\\\$ d' ../drat_sp/README.md # only keep first 1000 lines of readme

	git config --global user.email "sykdomspulsen@fhi.no"
	git config --global user.name "sykdomspulsen"

	git -C ../drat_sp add -A
	git -C ../drat_sp commit -am "gocd $(PKGNAME) $(PKGVERS)" #Committing the changes
	git -C ../drat_sp push -f origin gh-pages #pushes to master branch

	sudo chmod -R 777 ..

	# fhi
	git -C .. clone git@github.com:folkehelseinstituttet/drat.git --branch gh-pages drat_fhi
	sudo podman run --rm --privileged \
		-v $(shell pwd):/rpkg \
		-v $(shell pwd)/../built:/built \
		-v $(shell pwd)/../drat_fhi:/drat \
		docker.io/fhix/rfhiverse:latest /bin/bash -c 'Rscript -e "drat::insertPackage(fs::dir_ls(\"/built/\", regexp=\".tar.gz\$\"), repodir = \"/drat\")"'

	sed -i "/## News/a - **$(PKGNAME) $(PKGVERS)** (linux) inserted at $(DATETIME)" ../drat/README.md
	sed -i '1001,\\\$ d' ../drat_fhi/README.md # only keep first 1000 lines of readme

	git config --global user.email "sykdomspulsen@fhi.no"
	git config --global user.name "sykdomspulsen"

	git -C ../drat_fhi add -A
	git -C ../drat_fhi commit -am "gocd $(PKGNAME) $(PKGVERS)" #Committing the changes
	git -C ../drat_fhi push -f origin gh-pages #pushes to master branch

	sudo chmod -R 777 ..

.ONESHELL:
pkgdown:
	sudo podman run --rm --privileged \
		-v $(shell pwd):/rpkg \
		-v $(shell pwd)/../built:/built \
		-v $(shell pwd)/../drat_sp:/drat \
		docker.io/fhix/rfhiverse:latest /bin/bash -c 'Rscript -e "devtools::install(\"/rpkg\", dependencies = TRUE, upgrade = FALSE); pkgdown::build_site(\"/rpkg\")"'

	git add .
	git commit -am "Pkgdown built"
	git subtree split --prefix docs -b gh-pages # create a local gh-pages branch containing the splitted output folder
	git push -f origin gh-pages:gh-pages # force the push of the gh-pages branch to the remote gh-pages branch at origin
	git branch -D gh-pages # delete the local gh-pages because you will need it: ref

	sudo chmod -R 777 ..

.ONESHELL:
drat_prune_history:
	cd /tmp
	git clone "git@github.com:folkehelseinstituttet/drat.git"
	cd drat
	git config user.name "Sykdomspulsen"
	git config user.email "sykdomspulsen@fhi.no"
	git config push.default simple
	git checkout gh-pages

	git checkout --orphan latest_branch
	git add -A
	git commit -am "Cleaning history" #Committing the changes
	git branch -D gh-pages #Deleting master branch
	git branch -m gh-pages #renaming branch as master
	git -C /tmp/drat push -f origin gh-pages #pushes to master branch
