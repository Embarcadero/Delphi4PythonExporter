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
        self.editTotal.OnChange = self.editTotalChange
        self.editTotal.Value = 100
        self.editTip.Value = 20
        self.editPeople.Value = 4

    def calc_bill_plus_tip(self):
        total = self.editTotal.Value
        tip_percent = self.editTip.Value

        if total != 0:
            self.bill_plus_tip.Text = str(round(total + (tip_percent*total)/100, 2))
            print(round(total + (tip_percent/total)*100, 2))
        else:
            self.bill_plus_tip.Text = str(0)

    def calc_per_person_share(self):
        persons = self.editPeople.Value

        self.per_person_share.Text = str(round(float(self.bill_plus_tip.Text) / persons, 2))

    def editTotalChange(self, Sender):
        self.calc_bill_plus_tip()
        self.calc_per_person_share()

    def editTipChange(self, Sender):
        self.trackTip.Value = self.editTip.Value
        self.calc_bill_plus_tip()
        self.calc_per_person_share()

    def trackTipChange(self, Sender):
        self.editTip.Value = self.trackTip.Value
        self.calc_bill_plus_tip()
        self.calc_per_person_share()

    def editPeopleChange(self, Sender):
        self.trackPeople.Value = self.editPeople.Value
        self.calc_bill_plus_tip()
        self.calc_per_person_share()

    def trackPeopleChange(self, Sender):
        self.editPeople.Value = self.trackPeople.Value
        self.calc_bill_plus_tip()
        self.calc_per_person_share()

    def gold_style_btnClick(self, Sender):
        self.styleBook = self.styleGold

    def ruby_style_btnClick(self, Sender):
        self.styleBook = self.styleRuby

    def light_style_btnClick(self, Sender):
        self.styleBook = self.styleLight

    def default_styleClick(self, Sender):
        self.styleBook = None