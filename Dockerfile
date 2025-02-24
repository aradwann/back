FROM lukemathwalker/cargo-chef:latest-rust-1 AS chef

WORKDIR /app

FROM chef AS planner
COPY . .
RUN cargo chef prepare --recipe-path recipe.json

FROM chef AS builder

COPY --from=planner /app/recipe.json recipe.json
# Build dependencies - this is the caching Docker layer!
RUN cargo chef cook --release --recipe-path recipe.json
# Build application
COPY . .
ENV SQLX_OFFLINE=true
RUN cargo build --release


FROM debian:bookworm-slim AS runtime

COPY --from=builder /app/target/release/email_newsletter email_newsletter
COPY --from=builder /app/configuration configuration

ENV APP_ENV=production

ENTRYPOINT [ "./email_newsletter" ] 

