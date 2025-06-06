CREATE TABLE courses (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    credits INTEGER
);

CREATE TABLE registrations (
    id SERIAL PRIMARY KEY,
    student VARCHAR(100),
    course_id INTEGER REFERENCES courses(id)
);

INSERT INTO courses (name, credits) VALUES
('Intro to Computer Science', 3),
('Data Structures', 4),
('Web Development', 3),
('Cybersecurity Basics', 2);
