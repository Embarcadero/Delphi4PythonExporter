from delphifmx import *
from TipMain import Main_Window

def main():
    Application.Initialize()
    Application.Title = 'Tip Calculator'
    Application.MainForm = Main_Window(Application)
    Application.MainForm.Show()
    Application.Run()
    Application.MainForm.Destroy()

if __name__ == '__main__':
    main()
