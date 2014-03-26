Feature: Manage patients on the T4sklist
In order to keep a T4sklist of all patients that are part of the medical "Take"
As a staff member with appropriate rights
I want to make changes to the T4sklist to keep it accurate  
#this feature implements CRUD functions for T4sklist, taking into account some local business processes and clinical safety issues.

  Background:
    Given I am a logged in user

    Scenario: Add a patient to the T4sklist
      Given I have the right to Add a patient
      When a patient becomes part of the "Medical Take" # see process map
      Then I should click "Add Patient"
      And provide details to identify the patient
      And the patient will be added to the T4sklist
      And the patient's details should be shown as a row in the "Active Patients" list
      And complete demographic details are pulled from the PAS #other systems may also be polled at this point to acquire further information
      And the Medical Take Leader should be sent a T4sk