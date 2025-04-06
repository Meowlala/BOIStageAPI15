name: StageAPI Bug Submission Sheet
title: "[BUG]"
description: A sheet for submitting issues with StageAPI.
labels:
  - "Status: Pending Triage"
body:
  - type: checkboxes
    id: checkboxes-0
    attributes:
      label: REPENTOGON
      description: Were you using REPENTOGON when you experienced this bug?
      required: false
  - type: dropdown
    id: dropdown-1
    attributes:
      label: Version
      description: What version of the game were you running?
      required: true
      options:
        - Repentance
        - Repentance+
        - Afterbirth+
  - type: textarea
    id: textarea-2
    attributes:
      label: Description
      description: Please provide a detailed description of the behavior, in contrast
        to how it is meant to behave.
      required: true
      value: Be as descriptive as possible, do not simply say "it doesn't work." Ask
        yourself what about it doesn't work.
  - type: textarea
    id: textarea-3
    attributes:
      label: Mod List
      description: If applicable, please provide a list of relevant mods. Please try
        to reduce this list as much as possible before submitting a report by
        disabling mods and ensuring the problem is absolutely StageAPI's fault.
  - type: checkboxes
    id: checkboxes-4
    attributes:
      label: Confirmation of Assistance (If applicable)
      description: By checking this option, you agree to provide some assistance with
        the relevant issue. This helps us figure out whether an issue is a high
        priority, or is being handled.
