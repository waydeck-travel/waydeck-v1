import { test, expect } from "@playwright/test";

test.describe("Authentication Pages", () => {
    test("sign-in page renders correctly", async ({ page }) => {
        await page.goto("/auth/sign-in");

        // Check page title
        await expect(page).toHaveTitle(/Waydeck/i);

        // Check sign in form elements exist
        await expect(page.getByRole("heading", { name: /sign in/i })).toBeVisible();
        await expect(page.getByLabel(/email/i)).toBeVisible();
        await expect(page.getByLabel(/password/i)).toBeVisible();
        await expect(page.getByRole("button", { name: /sign in/i })).toBeVisible();

        // Check link to sign up
        await expect(page.getByRole("link", { name: /sign up/i })).toBeVisible();
    });

    test("sign-up page renders correctly", async ({ page }) => {
        await page.goto("/auth/sign-up");

        // Check page elements
        await expect(page.getByRole("heading", { name: /sign up|create account/i })).toBeVisible();
        await expect(page.getByLabel(/email/i)).toBeVisible();
        await expect(page.getByRole("button", { name: /sign up|create/i })).toBeVisible();

        // Check link to sign in
        await expect(page.getByRole("link", { name: /sign in/i })).toBeVisible();
    });

    test("can navigate between sign-in and sign-up", async ({ page }) => {
        // Start at sign-in
        await page.goto("/auth/sign-in");

        // Click sign up link
        await page.getByRole("link", { name: /sign up/i }).click();
        await expect(page).toHaveURL(/sign-up/);

        // Click sign in link
        await page.getByRole("link", { name: /sign in/i }).click();
        await expect(page).toHaveURL(/sign-in/);
    });

    test("shows validation errors for empty form submission", async ({ page }) => {
        await page.goto("/auth/sign-in");

        // Try to submit empty form
        await page.getByRole("button", { name: /sign in/i }).click();

        // Wait a moment for validation
        await page.waitForTimeout(500);

        // The form should show some indication of required fields
        // This could be HTML5 validation or custom error messages
        // At minimum, the form should not navigate away
        await expect(page).toHaveURL(/sign-in/);
    });
});

test.describe("Protected Routes", () => {
    test("redirects to sign-in when accessing /app/trips unauthenticated", async ({
        page,
    }) => {
        await page.goto("/app/trips");

        // Should be redirected to sign-in
        await expect(page).toHaveURL(/auth\/sign-in/);
    });

    test("redirects to sign-in when accessing /app/profile unauthenticated", async ({
        page,
    }) => {
        await page.goto("/app/profile");

        // Should be redirected to sign-in
        await expect(page).toHaveURL(/auth\/sign-in/);
    });
});

test.describe("Landing Page", () => {
    test("landing page renders", async ({ page }) => {
        await page.goto("/");

        // Check page loads
        await expect(page).toHaveTitle(/Waydeck/i);

        // Should have navigation to auth
        const signInLink = page.locator('a[href*="sign-in"]');
        await expect(signInLink.first()).toBeVisible();
    });
});
