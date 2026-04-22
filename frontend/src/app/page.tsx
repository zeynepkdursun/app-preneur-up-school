import { ArrowRight } from 'lucide-react'

export default function HomePage() {
  return (
    <main className="min-h-screen px-6 py-12 md:px-12">
      <div className="mx-auto max-w-3xl">
        <p className="mb-3 font-mono text-xs  tracking-[0.15em] text-[color:var(--color-text-secondary)]">
          SKINLENS MVP
        </p>
        <h1 className="text-balance font-serif text-4xl font-light tracking-[-0.02em] md:text-6xl">
          Hoş Geldiniz
        </h1>
        <p className="mt-5 max-w-prose text-pretty text-base leading-relaxed text-[color:var(--color-text-secondary)] md:text-lg">
          Ürün içeriklerini cilt tipine göre analiz eden uygulamanın frontend iskeleti hazır. Şimdi sıradaki adım:
          backend ile konuşup analiz akışını bağlamak.
        </p>

        <div className="mt-10 flex flex-wrap items-center gap-3">
          <a
            href="http://127.0.0.1:8080/api/v1/health"
            target="_blank"
            rel="noreferrer"
            className="inline-flex items-center gap-2 border border-[color:var(--color-sand)] bg-[color:var(--color-bg-secondary)] px-5 py-3 text-sm uppercase tracking-[0.15em] text-[color:var(--color-text-primary)] transition hover:border-[color:var(--color-text-secondary)]"
            aria-label="Backend health endpointini aç"
          >
            Backend Health <ArrowRight className="h-4 w-4" aria-hidden="true" />
          </a>
        </div>
      </div>
    </main>
  )
}

