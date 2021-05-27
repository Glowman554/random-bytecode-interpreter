const fs = require("fs");

var instruction_table = {
	"nop": {
		opcode: 0,
		args: 0,
		description: "No operation"
	},
	"load": {
		opcode: 1,
		args: 1,
		description: "Load from memory in work register"
	},
	"store": {
		opcode: 2,
		args: 1,
		description: "Load from work register into memory"
	},
	"call": {
		opcode: 3,
		args: 1,
		description: "Jump to label"
	},
	"return": {
		opcode: 4,
		args: 0,
		description: "Return from call"
	},
	"out": {
		opcode: 5,
		args: 0,
		description: "Output number in work register as ascii"
	},
	"exit": {
		opcode: 6,
		args: 0,
		description: "Stop execution"
	},
	"mov": {
		opcode: 7,
		args: 1,
		description: "Load value in work register"
	},
	"add": {
		opcode: 8,
		args: 1,
		description: "Add to work register"
	},
	"compare": {
		opcode: 9,
		args: 2,
		description: "Jumps to address if value matches with work register"
	},
	"sub": {
		opcode: 10,
		args: 1,
		description: "Sub from work register"
	},
	"jump": {
		opcode: 11,
		args: 1,
		description: "Jump to memory address (return wont work useful for loops)"
	},
	"compare-reverse": {
		opcode: 12,
		args: 2,
		description: "Jumps to address if value not matches with work register"
	},
}

if(process.argv[2] == "info") {
	console.log(instruction_table[process.argv[3]].description);
} else if(process.argv[2] == "compile") {
	var code = fs.readFileSync(process.argv[3]);
	code = code.toString().split("\n");
	//console.log(code);

	var labels = {};
	var instruction_ptr = 0;
	code.forEach(element => {
		var tmp = element.split(" ");
		try {
			var opcode_len = 1 + instruction_table[tmp.shift()].args * 2;
			instruction_ptr += opcode_len;
		} catch(_) {
			if(element.startsWith("label")) {
				labels[tmp[0]] = instruction_ptr;
			}
		}
	});
	//console.log(labels);

	var compiled_code = [];

	code.forEach(element => {
		var tmp = element.split(" ");
		try {
			var instruction = instruction_table[tmp.shift()];
			compiled_code.push(instruction.opcode);
			for (let index = 0; index < instruction.args; index++) {
				var arg = tmp.shift();
				if(isNaN(arg)) {
					arg = labels[arg];
				}
				//console.log(arg);
				compiled_code.push(arg >> 8);
				compiled_code.push(arg & 0x00FF)
			}
		} catch(_) {
			if(element.startsWith("label") || element == "") {
				return;
			}

			console.log("Warning: " + element);
		}
	});
	//console.log(compiled_code);

	fs.writeFileSync("code.asm", "code: db " + compiled_code.join(", "));

	console.log("Used " + Object.keys(labels).length + " labels and produced " + compiled_code.length + " bytes of code!");
	console.log("Used labels: " + Object.keys(labels).join(", "));
	console.log("Final code: " + compiled_code.join(", "));
}