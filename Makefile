# Important!
# Choose your model below by uncommenting the corresponding line.
# There is no need to do any other device specific modifications in the entire project.
#MODEL=TEENSY30
#MODEL=TEENSY31
#MODEL=TEENSY32
#MODEL=TEENSY35
MODEL=TEENSY36

# Package manager can be selected from Cargo or Cross.
# Use Cargo only if you have installed all dependencies. Dependencies can be found from Dockerfile
PKGMAN=cross
#PKGMAN=cargo

# --------------------------------------------
# The rest of makefile need not to be changed
# --------------------------------------------

# Following definition makes hopefully more understandable error message when
# model is not specified.
ifndef MODEL
    MODEL=PLEASE_SPECIFY_YOUR_TEENSY_MODEL_IN_MAKEFILE
endif

TARGET=thumbv7em-none-eabi
# Enable hard floating point with for teensy 3.5 and 3.6
ifeq ($(MODEL), TEENSY35)
    TARGET=thumbv7em-none-eabihf
endif
ifeq ($(MODEL), TEENSY36)
    TARGET=thumbv7em-none-eabihf
endif

BIN=teensy3-rs-demo
OUTDIR=target/$(TARGET)/release
HEXPATH=$(OUTDIR)/$(BIN).hex
BINPATH=$(OUTDIR)/$(BIN)

all:: $(BINPATH)

.PHONY: $(BINPATH)
$(BINPATH):
	$(PKGMAN) build --release --target $(TARGET) --features "$(MODEL)"

.PHONY: debug
debug:
	$(PKGMAN) build --target $(TARGET) --features "$(MODEL)" --verbose

# Run clippy linter. Some bad lints are suppressed. Also supress warnings
# generated by Bindgen, which seems to not be clippy compliant
.PHONY: clippy
clippy:
	$(PKGMAN) clippy --target $(TARGET) --features "$(MODEL)"

.PHONY: doc
doc:
	$(PKGMAN) doc --features TEENSY36 --target "$(TARGET)"

$(HEXPATH): $(BINPATH)
	arm-none-eabi-objcopy -O ihex -R .eeprom $(BINPATH) $(HEXPATH)

.PHONY: flash
flash: $(HEXPATH)
	teensy_loader_cli -w -s --mcu=$(MODEL) $(HEXPATH) -v

.PHONY: clean
clean:
	$(PKGMAN) clean
