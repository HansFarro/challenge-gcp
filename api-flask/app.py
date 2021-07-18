import os
from flask import Flask
app = Flask(__name__)

@app.route('/greetings')
def welcome():
  return 

@app.route('/square/<int:x>')
def shape(x):
  y = x**2
  return 'Result: %d' % y

if __name__ == '__main__':
  app.run(host='0.0.0.0', port=os.getenv('PORT'))