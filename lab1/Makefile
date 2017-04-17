COMPONENT=LedToRadioAppC
BUILD_EXTRA_DEPS=LedToRadioMsg.class

LedToRadioMsg.class: LedToRadioMsg.java
	javac LedToRadioMsg.java

LedToRadioMsg.java:
	mig java -target=null -java-classname=LedToRadioMsg LedToRadio.h LedToRadioMsg -o $@

include $(MAKERULES)
$(call TOSMake_include_snesor,mts300)
