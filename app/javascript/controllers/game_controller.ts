import { Controller } from "@hotwired/stimulus"

// Handles game throw selection and loading states
export default class GameController extends Controller {
  static targets = ["button", "loading"]

  declare buttonTargets: HTMLButtonElement[]
  declare loadingTarget: HTMLElement
  declare hasLoadingTarget: boolean

  submit(): void {
    // Disable all buttons to prevent double submission
    this.buttonTargets.forEach(button => {
      button.disabled = true
    })

    // Show loading indicator
    if (this.hasLoadingTarget) {
      this.loadingTarget.classList.remove("hidden")
    }
  }
}
