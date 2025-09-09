mod decoder;

use decoder::Decoder;

fn print_usage() {
    println!("Usage: tori <COMMAND>");
    println!("");
    println!("Commands:");
    println!("help                    prints this message");
    println!("decode [blob]           decodes the blob");
}

fn main() {
    let args: Vec<String> = std::env::args().collect();
    if args.len() < 2 {
        println!("Invalid number of arguments!");
        println!("Use: tori help");
        return;
    }

    let command = &args[1];
    if command == "help" {
        print_usage();
    } else if command == "decode" {
        if args.len() < 3 {
            println!("Expected bencoded value, got nothing!");
            println!("Use: tori help");
            return;
        }
        let blob = args[2].clone();
        let bencoder = Decoder::new(blob);
        let res = bencoder.run();
        match res {
            Err(err) => println!("{err}"),
            Ok(r) => println!("{r}"),
        }
    } else {
        println!("Invalid command!");
        println!("Use: tori help");
    }
}
