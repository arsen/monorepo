"use client";
import { Loader2 } from "lucide-react";
import { Slot } from "@radix-ui/react-slot"
import { cva, type VariantProps } from "class-variance-authority"

import { cn } from "@monorepo/ui/lib/utils";
import { forwardRef, useLayoutEffect, useRef, useCallback, useState } from "react";

const buttonVariants = cva(
  "relative inline-flex items-center justify-center gap-2 whitespace-nowrap rounded-md text-sm font-medium transition-all disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg:not([class*='size-'])]:size-4 shrink-0 [&_svg]:shrink-0 outline-none focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px] aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive",
  {
    variants: {
      variant: {
        default:
          "bg-primary text-primary-foreground shadow-xs hover:bg-primary/90 active:opacity-80",
        destructive:
          "bg-destructive text-white shadow-xs hover:bg-destructive/90 focus-visible:ring-destructive/20 dark:focus-visible:ring-destructive/40 dark:bg-destructive/60 active:opacity-70",
        outline:
          "border bg-background shadow-xs hover:bg-accent hover:text-accent-foreground dark:bg-input/30 dark:border-input dark:hover:bg-input/50 active:opacity-60",
        secondary:
          "bg-secondary text-secondary-foreground shadow-xs hover:bg-secondary/80 active:opacity-60",
        ghost:
          "hover:bg-accent hover:text-accent-foreground dark:hover:bg-accent/50 active:opacity-60",
        link: "text-primary underline-offset-4 hover:underline active:opacity-60",
        icon: "hover:bg-accent hover:text-accent-foreground dark:hover:bg-accent/50 active:opacity-60 rounded-full border",
      },
      size: {
        default: "h-9 px-4 py-2 has-[>svg]:px-3",
        sm: "h-8 rounded-md gap-1.5 px-3 has-[>svg]:px-2.5",
        lg: "h-10 rounded-md px-6 has-[>svg]:px-4 text-md",
        icon: "size-9",
      },
    },
    defaultVariants: {
      variant: "default",
      size: "default",
    },
  }
)

function Button({
  className,
  variant,
  size,
  asChild = false,
  ...props
}: React.ComponentProps<"button"> &
  VariantProps<typeof buttonVariants> & {
    asChild?: boolean
  }) {
  const Comp = asChild ? Slot : "button"

  return (
    <Comp
      data-slot="button"
      className={cn(buttonVariants({ variant, size, className }))}
      {...props}
    />
  )
}

export { Button, buttonVariants }


type ButtonProps = React.ComponentProps<typeof Button>



interface LoadingButtonProps extends ButtonProps {
  loading?: boolean;
}

const LoadingButton = forwardRef<HTMLButtonElement, LoadingButtonProps>(
  ({ children, loading, disabled, ...props }, ref) => {

    const buttonRef = useRef<HTMLButtonElement>(null);
    const [preservedSize, setPreservedSize] = useState<{ width: number; height: number } | null>(null);

    useLayoutEffect(() => {
      if (buttonRef.current) {
        const rect = buttonRef.current.getBoundingClientRect();
        setPreservedSize({ width: rect.width, height: rect.height });
      }
    }, []);

    const buttonStyle = preservedSize ? {
      minWidth: `${preservedSize.width}px`,
      minHeight: `${preservedSize.height}px`,
    } : {};

    // Merge the forwarded ref with the internal ref using useCallback
    const mergedRef = useCallback((node: HTMLButtonElement | null) => {
      buttonRef.current = node;
      
      if (typeof ref === 'function') {
        ref(node);
      } else if (ref) {
        ref.current = node;
      }
    }, [ref]);

    return (
      <Button ref={mergedRef} disabled={loading || disabled} style={buttonStyle} {...props}>
        {loading && <Loader2 className="mr-2 h-4 w-4 animate-spin absolute left-1/2 top-1/2 -translate-y-1/2 -translate-x-1/2" />}
        {!loading && children}
      </Button>
    );
  }
);

LoadingButton.displayName = "LoadingButton";

export { LoadingButton };