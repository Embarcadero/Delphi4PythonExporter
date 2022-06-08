import os
from delphifmx import *

class Parent_Form(Form):

    def __init__(self, owner):
        self.my_button = None
        self.enter_text_edit = None
        self.enter_text_label = None
        self.main_heading = None
        self.LoadProps(os.path.join(os.path.dirname(os.path.abspath(__file__)), "parent_window.pyfmx"))

    def my_buttonClick(self, Sender):
        pass
