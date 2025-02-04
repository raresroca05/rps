import { Controller } from "@hotwired/stimulus"

// Handles game throw selection and loading states
export default class GameController extends Controller {
  static targets = ["button", "loadingModal"]

  declare buttonTargets: HTMLButtonElement[]
  declare loadingModalTarget: HTMLElement
  declare hasLoadingModalTarget: boolean

  private selectedThrow: string | null = null

  submit(event: Event): void {
    // Prevent default form submission
    event.preventDefault()

    const clickedButton = event.submitter as HTMLButtonElement
    const throwName = clickedButton?.dataset.throw

    if (!throwName) return

    this.selectedThrow = throwName

    // Copy the clicked button's icon to the modal
    if (this.hasLoadingModalTarget) {
      const iconContainer = document.getElementById("player-throw-icon")
      const buttonIcon = clickedButton.querySelector("svg")
      if (iconContainer && buttonIcon) {
        iconContainer.innerHTML = buttonIcon.outerHTML
      }
    }

    // Disable all buttons
    this.buttonTargets.forEach(button => {
      button.disabled = true
    })

    // Show loading modal
    if (this.hasLoadingModalTarget) {
      this.loadingModalTarget.classList.remove("hidden")
    }

    // Wait 2.5 seconds then submit the form
    setTimeout(() => {
      this.submitForm()
    }, 2500)
  }

  private submitForm(): void {
    const form = this.element.querySelector("form") as HTMLFormElement
    if (!form || !this.selectedThrow) return

    // Create a hidden input for the throw value
    const hiddenInput = document.createElement("input")
    hiddenInput.type = "hidden"
    hiddenInput.name = "throw"
    hiddenInput.value = this.selectedThrow
    form.appendChild(hiddenInput)

    // Submit the form
    form.submit()
  }

  closeModal(): void {
    if (this.hasLoadingModalTarget) {
      this.loadingModalTarget.classList.add("hidden")
    }
    // Re-enable buttons
    this.buttonTargets.forEach(button => {
      button.disabled = false
    })
    this.selectedThrow = null
  }
}
