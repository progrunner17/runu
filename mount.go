// +build !linux

package main

import (
	goruntime "runtime"

	"github.com/opencontainers/runtime-spec/specs-go"
	"github.com/sirupsen/logrus"
)

func prepareMounts(_ *specs.Spec) error {
	logrus.Warnf("bind mout is not supported on %s", goruntime.GOOS)
	return nil
}
