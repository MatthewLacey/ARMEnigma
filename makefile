ASFLAGS=-g

# The default rule if none specified on the
# command line
all: final

final: final.o n2l.o l2n.o peputils.a
	ld -o final final.o n2l.o l2n.o peputils.a

final.o: final.s
	as $(ASFLAGS) -o final.o final.s

clean:
	rm -f *.o final

