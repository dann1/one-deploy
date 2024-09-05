SHELL := $(shell which bash)
SELF  := $(patsubst %/,%,$(dir $(abspath $(firstword $(MAKEFILE_LIST)))))

ONE_DEPLOY_URL ?= https://github.com/OpenNebula/one-deploy/blob/master/
ONE_DEPLOY_DIR ?= $(SELF)/../one-deploy/

README_PATHS := $(realpath $(shell find $(ONE_DEPLOY_DIR)/roles/ -type f -name README.md))

define SYS_REFERENCE_RB :=
require 'erb'
require 'markly'
one_deploy_url = '$(ONE_DEPLOY_URL)'
parsed = ARGV.sort.each_with_object([]) do |path, a|
    root = Markly.parse(File.read(path))
    a << [ root.first_child.to_plaintext.chomp.split('Role:')[1].strip,
           root.first_child.next.to_markdown.chomp,
           one_deploy_url + path.split('/one-deploy/')[1] ]
end
puts ERB.new(File.read('$(SELF)/sys_reference.erb'), :trim_mode => '-').result(binding)
endef

export

.PHONY: all gems

all: $(SELF)/sys_reference.md

gems:
	gem install --no-document markly

$(SELF)/sys_reference.md: $(SELF)/sys_reference.erb $(SELF)/Makefile $(README_PATHS)
	@ruby -- /dev/fd/0 $(wordlist 3, $(words $^), $^) > $@ <<< "$$SYS_REFERENCE_RB"
