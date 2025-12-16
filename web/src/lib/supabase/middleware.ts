import { createServerClient } from "@supabase/ssr";
import { NextResponse, type NextRequest } from "next/server";

export async function updateSession(request: NextRequest) {
    let supabaseResponse = NextResponse.next({
        request,
    });

    const supabase = createServerClient(
        process.env.NEXT_PUBLIC_SUPABASE_URL!,
        process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
        {
            cookies: {
                getAll() {
                    return request.cookies.getAll();
                },
                setAll(cookiesToSet) {
                    cookiesToSet.forEach(({ name, value }) =>
                        request.cookies.set(name, value)
                    );
                    supabaseResponse = NextResponse.next({
                        request,
                    });
                    cookiesToSet.forEach(({ name, value, options }) =>
                        supabaseResponse.cookies.set(name, value, options)
                    );
                },
            },
        }
    );

    // Avoid writing any logic between createServerClient and
    // supabase.auth.getUser(). A simple mistake could make it very hard to debug
    // issues with users being randomly logged out.

    const {
        data: { user },
        error,
    } = await supabase.auth.getUser();

    const isAppRoute = request.nextUrl.pathname.startsWith("/app");
    const isAuthRoute = request.nextUrl.pathname.startsWith("/auth");

    // Redirect unauthenticated users from /app/* to /auth/sign-in
    if (isAppRoute && !user) {
        console.log("[Middleware] Redirecting unauthenticated user to /auth/sign-in");
        const url = request.nextUrl.clone();
        url.pathname = "/auth/sign-in";
        return NextResponse.redirect(url);
    }

    // Redirect authenticated users from /auth/* to /app/trips
    if (isAuthRoute && user) {
        console.log("[Middleware] Redirecting authenticated user to /app/trips");
        const url = request.nextUrl.clone();
        url.pathname = "/app/trips";
        return NextResponse.redirect(url);
    }

    return supabaseResponse;
}
