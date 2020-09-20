use lazy_static::lazy_static;
use regex::Regex;

#[derive(Debug)]
pub struct Employee {
    pub f_name: String,
    pub l_name: String,
    pub emp_id: String,
    pub zip: String,
}

impl Employee {
    pub fn validate(&self) {
        // FIXME any way to make this 4-way test more concise?
        let e_f_name = self.validate_f_name();
        let e_l_name = self.validate_l_name();
        let e_emp_id = self.validate_emp_id();
        let e_zip = self.validate_zip();
        if e_f_name && e_l_name && e_emp_id && e_zip {
            println!("There were no errors found.");
        }
    }

    // private
    fn validate_f_name(&self) -> bool {
        if self.f_name.len() == 0 {
            println!("The first name must be filled in.");
            false
        } else if self.f_name.len() < 2 {
            println!("\"{}\" is not a valid first name. It is too short.", self.f_name);
            false
        } else {
            true
        }
    }

    // private
    fn validate_l_name(&self) -> bool {
        if self.l_name.len() == 0 {
            println!("The last name must be filled in.");
            false
        } else if self.l_name.len() < 2 {
            println!("\"{}\" is not a valid last name. It is too short.", self.l_name);
            false
        } else {
            true
        }
    }

    // private
    fn validate_emp_id(&self) -> bool {
        lazy_static! {
            static ref EMP_ID_RE: Regex = Regex::new(r"^(?i)[a-z]{2}-\d{4}$").unwrap();
        }
        if EMP_ID_RE.is_match(&self.emp_id) {
            true
        } else {
            println!("{} is not a valid ID.", self.emp_id);
            false
        }
    }

    // private
    fn validate_zip(&self) -> bool {
        lazy_static! {
            static ref ZIP_RE: Regex = Regex::new(r"^\d{5}(?:-\d{4})?$").unwrap();
        }
        if ZIP_RE.is_match(&self.zip) {
            true
        } else {
            println!("The ZIP code must be numeric.");
            false
        }
    }
}

// TODO write tests
