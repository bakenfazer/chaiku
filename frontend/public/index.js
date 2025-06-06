// Adjusted to use relative API path for NGINX proxy
const apiBase = '/api';

document.addEventListener('DOMContentLoaded', async () => {
  const root = document.getElementById('root');
  root.innerHTML = '<h1>Course Registration</h1><p>Loading courses...</p>';

  const courseList = document.createElement('ul');
  root.appendChild(courseList);

  try {
    const res = await fetch(`${apiBase}/courses`);
    if (!res.ok) throw new Error(`HTTP error! status: ${res.status}`);

    const courses = await res.json();
    root.querySelector('p').remove();

    if (courses.length === 0) {
      root.innerHTML += '<p>No courses available.</p>';
      return;
    }

    courses.forEach(course => {
      const li = document.createElement('li');
      li.textContent = `${course.name} (${course.credits} credits)`;

      const btn = document.createElement('button');
      btn.textContent = 'Register';
      btn.onclick = async () => {
        const response = await fetch(`${apiBase}/register`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({ student: 'jdoe@university.edu', course_id: course.id })
        });

        const data = await response.json();
        alert(data.message);
      };

      li.appendChild(btn);
      courseList.appendChild(li);
    });
  } catch (err) {
    root.innerHTML += `<p style="color:red;">Error loading courses: ${err.message}</p>`;
  }
});
