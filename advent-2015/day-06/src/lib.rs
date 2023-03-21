use custom_error::custom_error;
use std::str::FromStr;

#[derive(Debug, Clone, Copy, Eq, Hash, PartialEq)]
pub struct Position {
    pub y: u32,
    pub x: u32,
}

custom_error! {pub PositionError
    InvalidString{s: String} = "invalid string '{s}'",
    InvalidCoordinate{source: std::num::ParseIntError} = "non-integer coordinate",
}

impl FromStr for Position {
    type Err = PositionError;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let coordinates: Vec<u32> = s
            .split(',')
            .map(|dim| dim.parse::<u32>().map_err(Into::into))
            .collect::<Result<Vec<u32>, Self::Err>>()?;
        if coordinates.len() == 2 {
            Ok(Self {
                x: coordinates[0],
                y: coordinates[1],
            })
        } else {
            Err(PositionError::InvalidString { s: String::from(s) })
        }
    }
}

#[derive(Debug, PartialEq)]
pub struct Instruction {
    command: String,
    from_pos: Position,
    to_pos: Position,
}

custom_error! {pub InstructionError
    InvalidInstruction{s: String} = "invalid instruction '{s}'",
    InvalidCommand{s: String} = "invalid command '{s}'",
    InvalidPosition{source: PositionError} = "invalid position",
}

impl FromStr for Instruction {
    type Err = InstructionError;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let ns = s.replace("turn o", "turn_o");
        let tokens: Vec<&str> = ns.split_whitespace().collect();
        if tokens.len() != 4 || tokens[2] != "through" {
            return Err(Self::Err::InvalidInstruction { s: String::from(s) })
        }
        let command = String::from(tokens[0]);
        // FIXME
        //let from_pos = tokens[1].parse::<Position>().map_err(Into::into)?;
        //let to_pos = tokens[3].parse::<Position>().map_err(Into::into)?;
        let from_pos = tokens[1].parse::<Position>().unwrap();
        let to_pos = tokens[3].parse::<Position>().unwrap();
        match &command[..] {
            "turn_on" | "turn_off" | "toggle" => {
                Ok(Self { command, from_pos, to_pos })
            },
            _ => {
                Err(Self::Err::InvalidCommand { s: String::from(command) })
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_position_parse() {
        let exp = Position { y: 500, x: 499 };
        assert_eq!(exp, "499,500".parse().unwrap());
    }

    #[test]
    fn test_position_parse_invalid_string() {
        let e = "499,500,501".parse::<Position>().unwrap_err();
        assert_eq!("invalid string '499,500,501'", e.to_string());
    }

    #[test]
    fn test_position_parse_invalid_coordinate() {
        let e = "499xSOO".parse::<Position>().unwrap_err();
        assert_eq!("non-integer coordinate", e.to_string());
    }

    #[test]
    fn test_turn_on_instruction_parse() {
        let exp = Instruction {
            command: String::from("turn_on"),
            from_pos: Position { y: 21, x: 20 },
            to_pos: Position { y: 50, x: 49 },
        };
        assert_eq!(exp, "turn on 20,21 through 49,50".parse().unwrap());
    }

    #[test]
    fn test_turn_off_instruction_parse() {
        let exp = Instruction {
            command: String::from("turn_off"),
            from_pos: Position { y: 11, x: 10 },
            to_pos: Position { y: 30, x: 29 },
        };
        assert_eq!(exp, "turn off 10,11 through 29,30".parse().unwrap());
    }

    #[test]
    fn test_toggle_instruction_parse() {
        let exp = Instruction {
            command: String::from("toggle"),
            from_pos: Position { y: 41, x: 40 },
            to_pos: Position { y: 60, x: 59 },
        };
        assert_eq!(exp, "toggle 40,41 through 59,60".parse().unwrap());
    }

    #[test]
    fn test_instruction_parse_invalid() {
        let e = "turn off and on 0,1 through 9,10".parse::<Instruction>().unwrap_err();
        assert_eq!("invalid instruction 'turn off and on 0,1 through 9,10'", e.to_string());
        let e = "turn off 100,101 thru 129,130".parse::<Instruction>().unwrap_err();
        assert_eq!("invalid instruction 'turn off 100,101 thru 129,130'", e.to_string());
    }

    #[test]
    fn test_instruction_parse_invalid_command() {
        let e = "turn out 0,1 through 9,10".parse::<Instruction>().unwrap_err();
        assert_eq!("invalid command 'turn_out'", e.to_string());
    }

    #[test]
    fn test_instruction_parse_invalid_position() {
        // FIXME
        //let e = "turn off 0,1 through 9,IO".parse::<Instruction>().unwrap_err();
        //assert_eq!("invalid position", e.to_string());
    }
}
