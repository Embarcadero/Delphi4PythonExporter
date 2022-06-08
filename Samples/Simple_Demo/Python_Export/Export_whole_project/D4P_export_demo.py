from delphifmx import *
from parent_window import Parent_Form

def main():
    Application.Initialize()
    Application.Title = 'Exporter Demo'
    Application.MainForm = Parent_Form(Application)
    Application.MainForm.Show()
    Application.Run()
    Application.MainForm.Destroy()

if __name__ == '__main__':
    main()
