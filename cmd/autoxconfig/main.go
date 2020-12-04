package main

import (
	"github.com/haraldfw/autoxconfig/internal/version"
	log "github.com/sirupsen/logrus"
)

func main() {
	log.Infof("autoxconfig %s", version.VERSION)
}
