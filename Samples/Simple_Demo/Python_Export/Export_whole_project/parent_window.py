import os
from delphifmx import *
from child_window import Child_Form

class Parent_Form(Form):

    def __init__(self, owner):
        self.my_button = None
        self.enter_text_edit = None
        self.enter_text_label = None
        self.main_heading = None
        self.LoadProps(os.path.join(os.path.dirname(os.path.abspath(__file__)), "parent_window.pyfmx"))
        self.child_form = Child_Form(self)

    def my_buttonClick(self, Sender):
        self.child_form.result_text_label.Text = self.enter_text_edit.Text
        self.child_form.show()