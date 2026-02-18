FROM public.ecr.aws/docker/library/python:latest

WORKDIR /app
COPY . .
RUN pip install --no-cache-dir -r requirements.txt

CMD ["python", "wsgi.py"]
