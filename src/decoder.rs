pub enum DecodeErr {
    EmptyRoot,
    InvalidRoot,
}

pub struct Decoder {
    blob: String,
}

pub enum Element {
    Str(String),
    Num(i32)
}

impl std::fmt::Display for DecodeErr {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            DecodeErr::InvalidRoot => write!(f, "Blob has invalid root!"),
            DecodeErr::EmptyRoot => write!(f, "Empty blob given!"),
        }
    }
}

impl std::fmt::Display for Element {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Element::Str(s) => write!(f, "{s}"),
            Element::Num(i) => write!(f, "{i}"),
        }
    }
}


impl Decoder {
    pub fn new(blob: String) -> Self {
        Self { blob }
    }

    pub fn run(self) -> Result<Element, DecodeErr> {
        let first_ch = self.blob.chars().nth(0);
        if first_ch.is_none() {
            return Err(DecodeErr::EmptyRoot);
        }
        if self.blob.len() == 0 {
        }


        let ch = first_ch.unwrap();
        if ch == 'i' {
            return Ok(self.decode_num());
        }

        if ch == 'd' {
            return Ok(self.decode_dict());
        }

        if ch == 'l' {
            return Ok(self.decode_list());
        }

        if ch.is_ascii_digit() {
            return Ok(self.decode_string());
        }

        return Err(DecodeErr::InvalidRoot);

    }

    fn decode_string(self) -> Element {
        todo!();
    }

    fn decode_num(self) -> Element {
        let (num, rem) = self.blob;
        todo!();
    }

    fn decode_list(self) -> Element {
        todo!();
    }
    fn decode_dict(self) -> Element {
        todo!();
    }
}
