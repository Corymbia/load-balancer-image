#!/bin/bash
#
# Copyright 2009-2013 Eucalyptus Systems, Inc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 3 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see http://www.gnu.org/licenses/.
#
# Please contact Eucalyptus Systems, Inc., 6755 Hollister Ave., Goleta
# CA 93117, USA or visit http://www.eucalyptus.com/licenses/ if you need
# additional information or have any questions.

function insert_global()
{
    local spec=$1
    local var=$2
    local value=$3

    sed -i "1s/^/# This is a generated value\n%global $var $value\n\n/" $spec
}

BUILD_NUMBER=${BUILD_NUMBER:-0}

if [ -z "$GIT_COMMIT" ]; then
    GIT_COMMIT_SHORT=`git rev-parse --short HEAD`
else
    GIT_COMMIT_SHORT=${GIT_COMMIT:0:7}
fi

BUILD_ID=$BUILD_NUMBER.$(date +%y%m%d)git${GIT_COMMIT_SHORT}

[ -d ./build ] && rm -rf build
[ -d ./results ] && rm -rf results

mkdir -p build/{BUILD,BUILDROOT,SRPMS,RPMS,SOURCES,SPECS}

cp *.spec build/SPECS
cp *.tgz *.ks scripts/build-eustore-tarball.sh IMAGE-LICENSE build/SOURCES

SPECFILE=$(echo -n build/SPECS/*.spec)

insert_global $SPECFILE dist .el6
insert_global $SPECFILE build_id $BUILD_ID

#
# Setting the devbuild macro will append '-devel' to the package name
[ "$1" = "devel" ] && insert_global $SPECFILE devbuild 1

rpmbuild --define "_topdir `pwd`/build" \
    -ba build/SPECS/eucalyptus-load-balancer-image.spec

mkdir results
find build/ -name "*.rpm" -exec mv {} results/ \;

