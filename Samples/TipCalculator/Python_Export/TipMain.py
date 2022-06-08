import os
from delphifmx import *

class Main_Window(Form):

    def __init__(self, owner):
        self.styleRuby = None
        self.styleLight = None
        self.ListBox1 = None
        self.ListBoxItem1 = None
        self.editTotal = None
        self.Label6 = None
        self.ListBoxItem2 = None
        self.Label7 = None
        self.editTip = None
        self.ListBoxItem3 = None
        self.trackTip = None
        self.ListBoxItem4 = None
        self.editPeople = None
        self.Label3 = None
        self.ListBoxItem5 = None
        self.trackPeople = None
        self.ListBoxItem6 = None
        self.Layout2 = None
        self.ListBoxItem7 = None
        self.per_person_share = None
        self.Label1 = None
        self.ListBoxItem8 = None
        self.bill_plus_tip = None
        self.Label5 = None
        self.ListBoxItem9 = None
        self.gold_style_btn = None
        self.ruby_style_btn = None
        self.light_style_btn = None
        self.default_style = None
        self.styleGold = None
        self.LoadProps(os.path.join(os.path.dirname(os.path.abspath(__file__)), "TipMain.pyfmx"))

    def editTipChange(self, Sender):
        pass

    def trackTipChange(self, Sender):
        pass

    def editPeopleChange(self, Sender):
        pass

    def trackPeopleChange(self, Sender):
        pass

    def gold_style_btnClick(self, Sender):
        pass

    def ruby_style_btnClick(self, Sender):
        pass

    def light_style_btnClick(self, Sender):
        pass

    def default_styleClick(self, Sender):
        pass