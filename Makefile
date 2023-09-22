nn nn.o: nn.zig
	zig build-exe $?

clean: nn nn.o
	rm $?