# shelfcomponents
VHDL components ready to use in any design

Simulation dependencies:
- OSVVM
- GHDL

Early stage repository, it is a just for fun project...(with all the consequences)

Structure of components:
  - Name_of_component:
    - Sim:
      - *.vhd : all files needed for test
    - Src: 
      - *.vhd: files to be included on your desing

    - *.sh: Script for linux to test the component using GHDL and OSVVM
    
    - toDo.txt: things missing on the desing