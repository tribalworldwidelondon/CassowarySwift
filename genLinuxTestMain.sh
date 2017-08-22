#!/bin/sh

sourcery --sources Tests/ \
    --templates sourcery/LinuxMain.stencil \
    --args testimports='@testable import CassowaryTests'