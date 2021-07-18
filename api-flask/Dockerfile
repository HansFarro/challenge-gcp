FROM python:3.6
WORKDIR /usr/src/app/
COPY . /usr/src/app/
EXPOSE 5000
RUN pip install -r requirements.txt
CMD ["python", "app.py"]