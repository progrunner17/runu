package main

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"github.com/opencontainers/runtime-spec/specs-go"
	"golang.org/x/sys/unix"
)

func prepareMount(src, dest string) error {
	srcStat, err := os.Stat(src)
	if err != nil {
		return err
	}

	if _, err := os.Stat(dest); err != nil {
		if os.IsNotExist(err) {
			if srcStat.IsDir() {
				return os.MkdirAll(dest, 0755)
			}
			if err := os.MkdirAll(filepath.Dir(dest), 0755); err != nil {
				return err
			}
			f, err := os.OpenFile(dest, os.O_CREATE, 0755)
			if err != nil {
				return err
			}
			f.Close()
		}
	}
	return nil
}

func doMounts(spec *specs.Spec) error {

	rootfs := spec.Root.Path
	for _, m := range spec.Mounts {
		var (
			dest          = m.Destination
			flags uintptr = 0x0
		)
		if !strings.HasPrefix(dest, rootfs) {
			dest = filepath.Join(rootfs, dest)
		}

		for _, f := range m.Options {
			switch f {
			case "rbind":
				flags = flags | unix.MS_BIND | unix.MS_REC
			case "rprivate":
				flags = flags | unix.MS_PRIVATE | unix.MS_REC
			}

		}

		switch m.Type {
		case "bind":

			if m.Destination == "/etc/hosts" {
				break
			}

			if m.Destination == "/etc/hostname" {
				break
			}

			if m.Destination == "/etc/resolv.conf" {
				break
			}

			if m.Destination == "/dev/shm" {
				break
			}

			if err := prepareMount(m.Source, dest); err != nil {
				return err
			}

			if err := unix.Mount(m.Source, dest, "bind", flags, ""); err != nil {
				return fmt.Errorf("mount %s on %s failed", m.Source, dest)
			}
		}
	}
	return nil
}
